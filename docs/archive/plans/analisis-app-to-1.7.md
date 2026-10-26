# Análisis y plan de tareas — v1.6.2 → v1.7.0 (overlay + fixes)

**Fuente de auditoría:** `revision-app.md` (verificada línea por línea contra código real)
**Fecha:** 2026-07-28
**Archivos base:** `lib/` (~28.1k líneas Dart), `android/` (Kotlin + Gradle)

---

## Resumen ejecutivo

Todas las incidencias de `revision-app.md` fueron verificadas contra el código real. Se confirman **todos** los hallazgos. Este documento lista cada tarea como un ítem accionable con ubicación exacta, riesgo, fix concreto y archivos afectados.

---

## Bloque 0 — Bloqueantes inmediatos

### 0.1 `pubspec.yaml` ausente en el zip

| Campo | Valor |
|-------|-------|
| **Estado** | `find . -iname "pubspec*"` → sin resultados |
| **Archivos faltantes** | `pubspec.yaml`, `pubspec.lock`, `.metadata` |
| **Impacto** | Sin árbol de dependencias no se puede buildear ni verificar versiones de `flutter_riverpod`, `hive_flutter`, `floaty_chatheads`, `ota_update` |
| **Acción** | Confirmar que existen en el entorno real. Si se compartió el zip sin ellos por omisión, incluirlos para v1.7.0 |
| **Bloquea release** | Sí |

### 0.2 Credenciales de firma expuestas en `key.properties`

| Campo | Valor |
|-------|-------|
| **Archivo** | `android/key.properties` |
| **Contenido real** | `storePassword=zzxzz908`, `keyAlias=retired64`, `storeFile=/home/mikky/keystore.jks` |
| **Riesgo** | Si alguien obtuvo este zip, puede firmar APKs con la misma identidad (`applicationId` + firma) y publicar actualizaciones maliciosas indistinguibles |
| **Acción 1 (urgente)** | Rotar keystore si el archivo circuló fuera de tu máquina |
| **Acción 2 (proceso)** | No volver a incluir `key.properties` real en zips. Crear `android/key.properties.example` con valores dummy |
| **Acción 3 (proceso)** | `android/local.properties` también tiene rutas `/home/mikky/...`. No es sensible pero no debería viajar en zips compartidos |

---

## Bloque 1 — Fugas de memoria

### 1.1 `cleanupObservers()` nunca limpia — orden invertido

| Campo | Valor |
|-------|-------|
| **Archivo** | `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt` |
| **Líneas** | `:126-129` (`onDetachedFromActivity`), `:1025-1033` (`cleanupObservers`) |
| **Causa raíz** | `onDetachedFromActivity()` pone `activity = null` **antes** de `cleanupObservers()`. La función en `:1026` hace `val wm = activity?.let { WorkManager.getInstance(it) } ?: return` → como `activity` ya es null, `let` nunca se ejecuta y retorna inmediatamente sin remover ningún observer |
| **Impacto** | Cada rotación de pantalla con una descarga/instalación en vuelo deja `Observer<WorkInfo>` vivos en el `LiveData`, reteniendo la `Activity` anterior en memoria y acumulando observers redundantes |
| **Fix** | Invertir el orden — limpiar observers antes de anular `activity` |
| **Código actual** | `activity = null` → `cleanupObservers()` |
| **Código target** | `cleanupObservers()` → `activity = null` |
| **Esfuerzo** | 1 línea, trivial |

---

## Bloque 2 — Bugs funcionales

### 2.1 Redirects encadenados en `ModDownloadWorker`

| Campo | Valor |
|-------|-------|
| **Archivo** | `android/app/src/main/kotlin/mods/sm64cdpy/ModDownloadWorker.kt` |
| **Líneas** | `:89-99` |
| **Causa raíz** | Solo maneja **un** salto de redirect manual con `if (connection.responseCode in 300..399)`. Si la URL de redirect responde otro 3xx, el código cae a `connection.inputStream` sobre una respuesta 3xx vacía → `IOException` → `catch (e: Exception)` genérico → `Result.retry()` → WorkManager reintenta con backoff pero la URL sigue teniendo el mismo problema → bucle indefinido hasta agotar reintentos |
| **Escenario real** | Muy común en CDNs de GitHub Releases y servicios de acortado de URLs |
| **Problema adicional** | `Accept-Encoding: identity` no se re-aplica en la conexión de redirect |
| **Fix** | Envolver en loop acotado (máx. 5 saltos), replicar headers (`connectTimeout`, `readTimeout`, `Accept-Encoding`) en cada iteración |
| **Esfuerzo** | ~15 líneas |

### 2.2 Sanitización de ZIP con bypass de path-traversal (1-pass replace)

| Campo | Valor |
|-------|-------|
| **Archivos** | `android/.../ModInstallWorker.kt:376-383`, `android/.../ModInstallerPlugin.kt:1208-1215` |
| **Nota** | Código **duplicado** en ambos archivos — hay que aplicar el fix en los dos |
| **Causa raíz** | `.replace("../", "").replace("..\\", "")` hace **un solo pase**. Entradas como `"..././evil.lua"` o `"....//evil.lua"` pueden recombinarse en `"../"` después del replace al eliminar los caracteres intermedios |
| **Mitigante real** | La extracción usa `DocumentFile` (SAF) → probablemente solo crea una carpeta literal `..` dentro del árbol autorizado sin escapar. Pero esto **varía según el proveedor de almacenamiento del dispositivo**, no es garantía universal |
| **Fix** | Reemplazar por segmentación explícita que **rechaza** cualquier segmento `..` o `.` en vez de intentar "limpiarlo" con replaces de texto |
| **Código target** |  |
| ```kotlin
| private fun sanitizeEntryName(name: String): String {
|     var sanitized = name.trim().replace("\\", "/").replace("\u0000", "")
|     while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
|     val parts = sanitized.split("/").filter { it.isNotEmpty() && it != "." && it != ".." }
|     return parts.joinToString("/")
| }
| ``` |
| **Esfuerzo** | 6 líneas × 2 archivos |

### 2.3 Race condition en `ThemeNotifier._box` / `LocaleNotifier._box`

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/presentation/providers/theme_provider.dart:158-166` |
| **Mismo patrón en** | `LocaleNotifier` (líneas `:116-141` del mismo archivo) |
| **Causa raíz** | `_box` es `late final Box<String>`, se asigna en `_loadSavedTheme()` que corre con `Future.microtask(() => _loadSavedTheme())`. Si el usuario toca el toggle de tema **inmediatamente** al abrir la app (antes de que `Hive.openBox` resuelva), `_box.put()` lanza `LateInitializationError` capturado por `catch (e) { debugPrint(...) }` → el tema cambia visualmente en esa sesión pero no se persiste en disco |
| **Efecto para el usuario** | El toggle funciona en esa sesión pero al reabrir la app vuelve al valor anterior — sin ningún mensaje de error |
| **Fix** | Abrir la Hive box en `main()` antes de `runApp()`, o guardar `Future<Box<String>>` y hacer `await` sobre ella en `setThemeMode`/`setLocale`. La opción más limpia es inicializar la box en `main()` junto al resto de la inicialización |
| **Esfuerzo** | ~5 líneas (mover `Hive.openBox` a `main()`) |

### 2.4 `importFavourites` usa `String.fromCharCodes` en vez de `utf8.decode`

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/presentation/providers/mod_providers.dart:330` |
| **Causa raíz** | `String.fromCharCodes(bytes)` interpreta cada entero como unidad de código UTF-16, no como byte UTF-8. Funciona por accidente para ASCII puro (IDs de mods), pero corrompe texto no-ASCII |
| **Fix** | `final raw = utf8.decode(bytes);` — `dart:convert` ya está importado en ese archivo |
| **Esfuerzo** | 1 línea |

### 2.5 `_titleByModName` crece indefinidamente en `OverlayBridge`

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/overlay/overlay_bridge.dart:14` (declaración), `:71` (escritura) |
| **Causa raíz** | `_titleByModName[modName] = modTitle` se ejecuta en cada descarga pero nunca se remueve la entrada. Ni al completar (`BgInstallCompleted`), ni al cancelar (`BgOperationCancelled`), ni al fallar (`BgInstallError`) |
| **Impacto** | Fuga de memoria acumulativa. Para uso normal el impacto es marginal (mapa de strings pequeño), pero es una fuga real que crece con cada instalación durante toda la vida del proceso |
| **Fix** | En `_forwardEventToOverlay`, agregar `_titleByModName.remove(event.modName)` cuando el evento es `BgInstallCompleted`, `BgOperationCancelled`, o `BgInstallError` |
| **Esfuerzo** | 2 líneas |

### 2.6 Fallback de `_inferFileName` sin extensión

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/services/download_url_resolver.dart:51` |
| **Causa raíz** | Las dos ramas anteriores de `_inferFileName` (`:28-31` y `:34-39`) sí garantizan extensión (`.zip` o la detectada). Pero la rama final del fallback (`:48-51`) retorna `'$safeName$suffix'` sin ninguna extensión |
| **Impacto** | Esto puede llegar hasta `ModDownloadWorker.kt` donde `isZipFile()` chequea `file.extension.equals("zip", ...)` → un archivo sin extensión nunca calificará como ZIP y se copiará sin extraer |
| **Fix** | `return '$safeName$suffix.zip';` |
| **Esfuerzo** | 1 carácter (`.zip`) |

---

## Bloque 3 — Fallos silenciosos sin feedback al usuario

### 3.1 Links externos rotos silenciosamente (`_launch` en app_drawer)

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/presentation/widgets/app_drawer.dart:884` |
| **Causa raíz** | `catch (_) {}` en `launchUrl(uri, mode: LaunchMode.externalApplication)` — si falla (no hay app que maneje el URI, restricción del sistema), el usuario toca el botón y no pasa nada: sin snackbar, sin toast, sin indicación visual |
| **Botones afectados** | Discord, YouTube, Wiki, GitHub, Tools and Addons, etc. — todos los `_LinkTile` usan este mismo `_launch()` |
| **Fix** | Usar `AppSnackbar` (ya existe en `lib/presentation/widgets/app_snackbar.dart`) dentro del catch |
| **Esfuerzo** | 3 líneas |

### 3.2 Overlay que no arranca — error silencioso

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/presentation/screens/settings_screen.dart:1340` |
| **Causa raíz** | `catch (_) {}` alrededor de `FloatyChatheads.showChatHead()` — si falla (falta permiso `SYSTEM_ALERT_WINDOW`, error del `FlutterEngine`, etc.), el spinner simplemente se apaga sin ninguna explicación |
| **Fix** | Agregar snackbar de error indicando "Permission denied" o "Failed to start overlay. Check 'Draw over other apps' permission" |
| **Esfuerzo** | 3 líneas |

### 3.3 Checks de carpeta en settings — fallo silencioso (baja)

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/presentation/screens/settings_screen.dart:412, 524` |
| **Riesgo** | Bajo — solo afecta el estado inicial del check visual, se puede reintentar manualmente |
| **Fix** | Agregar `debugPrint` para diagnosticar en desarrollo. No requiere snackbar |

### 3.4 `_extractFilename` en mod_detail — fallo silencioso (baja)

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/presentation/screens/mod_detail_screen.dart:785` |
| **Riesgo** | Bajo — hay fallback `url.split('/').last` |
| **Fix** | Agregar `debugPrint` para diagnosticar en desarrollo |

### 3.5 Datasources — fallo al leer JSON local (aceptable)

| Campo | Valor |
|-------|-------|
| **Archivos** | `lib/data/datasource/{local_mod,vip_mod,dynos,touch_control,omm_rebirth}_datasource.dart` (líneas ~56, ~143 y equivalentes en cada uno) |
| **Riesgo** | Aceptable — cae al bundled de assets, comportamiento documentado en comentarios |
| **Fix** | No prioritario para v1.7.0 |

---

## Bloque 4 — Duplicación estructural (refactor, post-1.7.0)

### 4.1 5 datasources copy-paste

| Campo | Valor |
|-------|-------|
| **Archivos** | `lib/data/datasource/{local_mod,vip_mod,dynos,touch_control,omm_rebirth}_datasource.dart` |
| **Problema** | Mismo flujo copy-paste: cache → JSON local → JSON bundled → fetch remoto → parseo. Solo cambian: nombre de clase, URL remota y clave del JSON (`mods`, `vip_mods`, `dynos`, `touch_controls`, `omm_mods`) |
| **Impacto** | ~700 líneas duplicadas. Cualquier fix futuro a la lógica de cache/fetch/retry debe aplicarse 5 veces |
| **Fix sugerido** | Extraer clase genérica `RemoteJsonDatasource<T>` parametrizada por URL + clave JSON + `fromJson`. Cada datasource concreto sería una instancia parametrizada. Reduce ~700 líneas a <200 |
| **Decisión** | **Posponer post-1.7.0** — no bloquea el release y el refactor es grande |

---

## Bloque 5 — Fuentes de verdad duplicadas / desincronizables

### 5.1 Número de versión hardcodeado en 3 lugares

| Campo | Valor |
|-------|-------|
| **Archivos** | `android/local.properties` (`flutter.versionName=1.6.2`), `lib/core/constants/app_constants.dart:18` (`appVersion = '1.6.2'`), `lib/services/update_service.dart:34` (`currentVersion` via `PackageInfo`) |
| **Dónde se usa `AppConstants.appVersion` en UI** | `disclaimer_screen.dart:76,117,179`, `settings_screen.dart:106`, `app_drawer.dart:184` |
| **Problema** | `UpdateService.currentVersion` ya resuelve la versión real (`PackageInfo.fromPlatform()`) en `main()` antes de `runApp()`. Pero disclaimer/settings/drawer usan `AppConstants.appVersion` hardcodeada. Si se cambia `pubspec.yaml`/Gradle y no se actualiza `AppConstants`, la UI muestra versión incorrecta mientras el sistema de updates compara contra la real |
| **Fix** | Reemplazar todos los usos de `AppConstants.appVersion` por `UpdateService.currentVersion`. Eliminar `AppConstants.appVersion` |
| **Esfuerzo** | ~6 líneas de cambio, 4 archivos |

### 5.2 URL de releases hardcodeada en 4 lugares

| Campo | Valor |
|-------|-------|
| **Ubicaciones** | `app_constants.dart:22` (`githubReleasesUrl`), `update_service.dart:18` (`_githubApiUrl`), `local_mod_datasource.dart:31` (`_remoteUrl`), `update_dialog.dart:144` (literal inline) |
| **Análisis** | Las URLs son **URLs diferentes**: página web de releases, API, raw.githubusercontent, y literal inline. Solo la de `update_dialog.dart:144` es una duplicación real de `githubReleasesUrl` |
| **Fix** | Mover el literal de `update_dialog.dart:144` a `AppConstants` (ej. `githubReleasesLatestUrl`) y usar la constante en `update_dialog.dart`. Las demás URLs tienen propósitos distintos — no unificar innecesariamente |
| **Esfuerzo** | 2 archivos, 2 líneas |

### 5.3 Constante muerta `favoritesBoxKey`

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/core/constants/app_constants.dart:9` |
| **Verificación** | `rg "favoritesBoxKey"` en todo `lib/` → solo retorna la declaración. 0 usos |
| **Contexto** | La persistencia de favoritos ya migró de Hive a SharedPreferences. La clave activa es `favouritesKey` (UK spelling, `:55`), no `favoritesBoxKey` (US spelling, apuntaba a Hive) |
| **Fix** | Eliminar la línea |
| **Esfuerzo** | 1 línea |

---

## Bloque 6 — Hallazgos menores

### 6.1 `FileDownloader.setLogEnabled(true)` en builds de release

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/main.dart:32` |
| **Problema** | `FileDownloader.setLogEnabled(true)` se ejecuta incondicionalmente, también en APKs de release. El comentario dice "Enable logs for debugging" pero no respeta `kDebugMode` |
| **Fix** | `FileDownloader.setLogEnabled(kDebugMode)` |
| **Esfuerzo** | 1 línea |

### 6.2 `BackgroundInstallService.dispose()` nunca invocado

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/services/background_install_service.dart:122-127` |
| **Verificación** | `rg "BackgroundInstallService.*dispose"` en todo `lib/` → 0 resultados. El método existe (cierra stream, cancela suscripción `_eventSub`, limpia `_infoMap`) pero **nadie lo llama nunca** |
| **Fix** | O conectarlo a un lifecycle real, o eliminarlo. Si se mantiene, llamarlo desde algún `WidgetsBindingObserver.didChangeAppLifecycleState` o desde el dispose de la app principal |
| **Esfuerzo** | 2 líneas (eliminar) o ~10 líneas (conectar a lifecycle) |

### 6.3 `pendingResult` compartido entre dos pickers SAF

| Campo | Valor |
|-------|-------|
| **Archivo** | `android/.../ModInstallerPlugin.kt` — `openDirectoryPicker` y `openDynosPicker` |
| **Problema** | Ambos métodos escriben el mismo campo `pendingResult`. Si se disparan simultáneamente (doble tap rápido, poco probable en producción pero posible en testing), el segundo pisa al primero → el callback de Flutter que esperaba la respuesta original queda sin resolver nunca |
| **Fix** | Usar campos separados: `pendingModPickerResult` y `pendingDynosPickerResult` |
| **Esfuerzo** | ~10 líneas |

### 6.4 Comentarios boilerplate obsoletos en `build.gradle.kts`

| Campo | Valor |
|-------|-------|
| **Archivo** | `android/app/build.gradle.kts` |
| **Comentarios** | `// TODO: Specify your own unique Application ID`, `// TODO: Add your own signing config` |
| **Estado real** | Ya hay `applicationId` y `signingConfig` reales definidos. Los TODOs quedaron como ruido |
| **Fix** | Borrar ambos comentarios |
| **Esfuerzo** | 2 líneas |

### 6.5 `hasLocalDb` — llamada síncrona en función async

| Campo | Valor |
|-------|-------|
| **Archivo** | `lib/data/datasource/local_mod_datasource.dart:151` |
| **Problema** | `file.existsSync()` (bloqueante) dentro de una función `async` que en el resto del archivo usa siempre las variantes async (`file.exists()`) |
| **Fix** | `await file.exists()` |
| **Esfuerzo** | 1 línea |

---

## Bloque 7 — Pendientes del overlay (work in progress, no bugs de v1.6.2)

### 7.1 Restaurar `activeInstalls` al reabrir el overlay

| Campo | Valor |
|-------|-------|
| **Problema** | Si una descarga está en progreso desde la app principal y el usuario abre el overlay, el panel no muestra esa descarga activa porque `BackgroundInstallService.instance.activeInstalls` nunca se comparte al overlay al abrirse |
| **Fix** | En el handler de `type == 'panel_opened'`, enviar al overlay el estado actual de `activeInstalls` via `FloatyChatheads.shareData()` |
| **Esfuerzo** | ~15 líneas |

### 7.2 Toggle de auto-install desde el overlay (mini-settings)

| Campo | Valor |
|-------|-------|
| **Problema** | El overlay no tiene forma de activar/desactivar auto-install. El usuario debe abrir la app principal para cambiar ese ajuste |
| **Fix** | Agregar un `SwitchListTile` o toggle en el panel del overlay que lea/escriba `SharedPreferences` para `autoInstallModsKey` y sincronice con el bridge |
| **Esfuerzo** | ~20 líneas |

---

## Checklist priorizado (orden de aplicación)

```
[01] 0.2  key.properties — rotar keystore si circuló, crear .example
[02] 0.1  pubspec.yaml — confirmar que existe en el entorno de build
[03] 1.1  ModInstallerPlugin.kt:126-127 — invertir onDetachedFromActivity
[04] 2.2  sanitizeEntryName × 2 — reemplazar por split/filter (ModInstallWorker + ModInstallerPlugin)
[05] 2.1  ModDownloadWorker.kt:89-99 — loop de redirects (máx 5 saltos)
[06] 2.3  theme_provider.dart — evitar LateInitializationError (mover Hive.openBox a main)
[07] 2.4  mod_providers.dart:330 — utf8.decode en vez de String.fromCharCodes
[08] 2.6  download_url_resolver.dart:51 — agregar .zip al fallback
[09] 2.5  overlay_bridge.dart — limpiar _titleByModName al terminar (completed/cancelled/error)
[10] 3.1  app_drawer.dart:884 — snackbar si launchUrl falla
[11] 3.2  settings_screen.dart:1340 — snackbar si overlay falla
[12] 5.1  Reemplazar AppConstants.appVersion → UpdateService.currentVersion (4 archivos)
[13] 5.3  app_constants.dart:9 — eliminar favoritesBoxKey (código muerto)
[14] 5.2  update_dialog.dart:144 — mover literal a AppConstants.githubReleasesLatestUrl
[15] 6.1  main.dart:32 — setLogEnabled(kDebugMode)
[16] 6.5  local_mod_datasource.dart:151 — existsSync → await exists
[17] 6.4  build.gradle.kts — borrar comentarios TODO boilerplate
[18] 6.2  background_install_service.dart:122 — eliminar dispose() o conectarlo a lifecycle
[19] 6.3  ModInstallerPlugin.kt — separar pendingResult en 2 campos
[20] 7.1  overlay_bridge.dart — restaurar activeInstalls al reabrir overlay
[21] 7.2  overlay_panel.dart — toggle auto-install en mini-settings del overlay
[22] 4.1  data sources — refactor a clase genérica RemoteJsonDatasource<T> (POST-1.7.0)
```

---

## Índice de archivos afectados

| Archivo | Items |
|---------|-------|
| `android/app/src/main/kotlin/.../ModInstallerPlugin.kt` | 1.1, 2.2, 6.3 |
| `android/app/src/main/kotlin/.../ModDownloadWorker.kt` | 2.1 |
| `android/app/src/main/kotlin/.../ModInstallWorker.kt` | 2.2 |
| `android/app/build.gradle.kts` | 6.4 |
| `android/key.properties` | 0.2 |
| `lib/core/constants/app_constants.dart` | 5.1, 5.2, 5.3 |
| `lib/services/download_url_resolver.dart` | 2.6 |
| `lib/services/background_install_service.dart` | 6.2 |
| `lib/services/update_service.dart` | (fuente de verdad para 5.1) |
| `lib/overlay/overlay_bridge.dart` | 2.5, 7.1 |
| `lib/overlay/overlay_panel.dart` | 7.2 |
| `lib/presentation/providers/theme_provider.dart` | 2.3 |
| `lib/presentation/providers/mod_providers.dart` | 2.4 |
| `lib/presentation/widgets/app_drawer.dart` | 3.1, 5.1 |
| `lib/presentation/screens/settings_screen.dart` | 3.2, 5.1 |
| `lib/presentation/screens/disclaimer_screen.dart` | 5.1 |
| `lib/widgets/update_dialog.dart` | 5.2 |
| `lib/data/datasource/local_mod_datasource.dart` | 6.5 |
| `lib/data/datasource/{vip, dynos, touch, omm}_*_datasource.dart` | 4.1 (post-1.7.0) |
| `lib/main.dart` | 2.3, 6.1 |
