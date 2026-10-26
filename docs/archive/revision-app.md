# Revisión técnica — SM64CDPY (Mod Manager)
**Objetivo:** identificar código roto, incompleto, fugas silenciosas y deuda técnica antes de congelar la versión estable **1.7.0**.
**Alcance analizado:** `lib/` (Flutter/Dart, ~28.1k líneas), `android/` (Kotlin nativo + Gradle), recursos y localización.
**Metodología:** lectura completa de los servicios core, diffing de datasources duplicados, búsqueda dirigida de `catch` vacíos, constantes no usadas, condiciones de carrera y verificación cruzada Dart↔Kotlin de cada MethodChannel/EventChannel.

Version actual detectada: `1.6.2` (`android/local.properties`, `AppConstants.appVersion`). Este documento asume que se corrige hacia `1.7.0`.

---

## 0. Bloqueante inmediato — falta `pubspec.yaml`

El zip entregado **no contiene `pubspec.yaml` ni `pubspec.lock` ni `.metadata`**. Solo vienen `lib/` y `android/`.

```
$ find . -iname "pubspec*"
(sin resultados)
```

Sin ese archivo no se puede reconstruir el árbol de dependencias exacto (versiones de `flutter_riverpod`, `hive_flutter`, `ota_update`, `floaty_chatheads`, `file_picker`, `share_plus`, etc.), ni confirmar `AppConstants.appVersion` contra la fuente real. Si fue un descuido al empaquetar el zip, es lo primero a resolver — cualquier intento de build fallará de inmediato. Si fue intencional (para no exponer rutas locales), avísame y trabajo solo con lo que hay, pero para el corte de 1.7.0 vas a necesitar subir ese archivo también.

---

## 1. Seguridad — credenciales de firma expuestas

**Archivo:** `android/key.properties`

```properties
storePassword=zzxzz908
keyPassword=zzxzz908
keyAlias=retired64
storeFile=/home/mikky/keystore.jks
```

- `android/.gitignore` (línea con `key.properties`, `**/*.jks`) confirma que esto **no debería** salir del equipo de desarrollo, pero el archivo viene incluido en el zip con la contraseña real del keystore en texto plano.
- Si este keystore es el que firma los releases publicados en `retired64/sm64cdpy.releases` (ver sección 2), cualquiera con este archivo puede firmar APKs que Android tratará como "la misma app" (mismo `applicationId` + misma firma) y publicar actualizaciones maliciosas indistinguibles de las tuyas para usuarios existentes.

**Acción recomendada antes de 1.7.0:**
1. Si este zip salió de tu propia máquina y nunca se subió a un repo público, probablemente no hay compromiso real — pero cambia igual la contraseña del keystore y evita volver a empaquetar `key.properties` cuando compartas el proyecto (usa `android/key.properties.example` con valores dummy).
2. Si en algún momento este archivo llegó a un repo (aunque sea privado) o a un zip que circuló, **rota el keystore** apenas puedas, aunque implique un cambio de firma incómodo para usuarios existentes.
3. `android/local.properties` también viene con rutas absolutas de tu máquina (`/home/mikky/...`) — no es sensible pero tampoco debería versionarse; ya está en `.gitignore`, solo cuida no volver a incluirlo en zips que compartas.

---

## 2. Bugs funcionales / fugas silenciosas (lo que pediste explícitamente)

### 2.1 `cleanupObservers()` nunca limpia nada — fuga de `Observer<WorkInfo>` en cada rotación de pantalla

**Archivo:** `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt`, líneas 126-129 y 1025-1033

```kotlin
override fun onDetachedFromActivity() {
    activity = null          // <- se limpia ANTES
    cleanupObservers()
}
...
private fun cleanupObservers() {
    val wm = activity?.let { WorkManager.getInstance(it) } ?: return   // <- activity ya es null → return inmediato
    for ((workId, observer) in workObservers) {
        try {
            wm.getWorkInfoByIdLiveData(workId).removeObserver(observer)
        } catch (_: Exception) { }
    }
    workObservers.clear()
}
```

`activity` se pone en `null` **antes** de llamar a `cleanupObservers()`, y esa función corta con `?: return` si `activity` es `null`. Resultado: la función nunca remueve nada ni limpia el mapa `workObservers`.

`onDetachedFromActivity()` se dispara en cada cambio de configuración (rotación de pantalla, cambio de idioma del sistema, split-screen) vía `onDetachedFromActivityForConfigChanges()` → `onDetachedFromActivity()`. Cada vez que esto pasa mientras hay una instalación en curso (o incluso después de que terminó, si el observer aún no se auto-removió), el `Observer<WorkInfo>` queda **registrado para siempre** en el `LiveData` de WorkManager, sin nadie que lo retire.

**Impacto:**
- Fuga de memoria acumulativa: cada rotación con una descarga/instalación en vuelo dobla observers vivos.
- Los observers viejos referencian (por closure) el `act: Activity` y el `modName` del momento en que se crearon — eso retiene la `Activity` anterior en memoria más de lo debido.
- Puede provocar que eventos de WorkManager se reenvíen más de una vez hacia Flutter vía `EventChannel` si el mismo `workId` sigue siendo observado por múltiples observers acumulados (no debería duplicar valores, pero sí trabajo/CPU innecesario).

**Fix sugerido:** invertir el orden — limpiar observers primero, luego poner `activity = null`:

```kotlin
override fun onDetachedFromActivity() {
    cleanupObservers()
    activity = null
}
```

---

### 2.2 Descargas OTA con redirect encadenado (>1 hop) fallan en bucle silencioso

**Archivo:** `android/app/src/main/kotlin/mods/sm64cdpy/ModDownloadWorker.kt`, líneas 89-99

```kotlin
if (connection.responseCode in 300..399) {
    val redirectUrl = connection.getHeaderField("Location")
    connection.disconnect()
    if (redirectUrl != null) {
        connection = URL(redirectUrl).openConnection() as HttpURLConnection
        connection.instanceFollowRedirects = false   // ← ya no sigue más redirects
        ...
        connection.connect()
    }
}
```

Solo se maneja **un** salto de redirección manual. Si la segunda URL (muy común en CDNs de GitHub Releases, servicios de acortado, o mirrors) responde con **otro** 3xx, el código sigue directo a `connection.inputStream` sobre una respuesta 3xx sin cuerpo, lo cual lanza `IOException`. Esa excepción cae en el `catch (e: Exception)` genérico de `doWork()` (líneas 67-71), que borra el archivo parcial y hace `Result.retry()` — WorkManager reintenta con backoff, pero como la URL sigue teniendo el mismo problema, **vuelve a fallar indefinidamente hasta agotar los reintentos**, y el usuario solo ve "descarga fallida" sin ninguna pista de que fue por una cadena de redirects.

También nota: `Accept-Encoding: identity` se setea en la conexión original pero **no** se re-aplica a la conexión de redirect — no es grave (solo afecta si el segundo servidor decide comprimir la respuesta), pero es inconsistente.

**Fix sugerido:** envolver la lógica de redirect en un loop acotado (p. ej. máx. 5 saltos) en lugar de un solo `if`, y replicar los headers relevantes en cada salto.

---

### 2.3 Sanitización de rutas ZIP con bypass conocido (defensa en profundidad incompleta)

**Archivos:**
- `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallWorker.kt`, líneas 375-383
- `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt`, líneas 1204-1212 (idéntica, código duplicado)

```kotlin
private fun sanitizeEntryName(name: String): String {
    var sanitized = name.trim()
    while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
    sanitized = sanitized.replace("../", "").replace("..\\", "")   // ← un solo pase, no recursivo
    sanitized = sanitized.replace("\\", "/")
    sanitized = sanitized.replace("\u0000", "")
    return sanitized
}
```

`.replace("../", "")` hace **una sola pasada**. Es el bypass clásico de filtros de path-traversal: una entrada de ZIP con nombre tipo `"..././evil.lua"` o `"....//evil.lua"` puede sobrevivir a un único `replace` y seguir conteniendo `"../"` después de la sustracción (al remover la ocurrencia intermedia, los caracteres restantes se recombinan en una nueva secuencia `"../"`).

**Mitigante real:** como la extracción usa `DocumentFile` (Storage Access Framework) para crear subcarpetas por *nombre de hijo* dentro del árbol ya autorizado (no resuelve rutas de sistema de archivos con `..` como "subir de directorio"), el impacto práctico probablemente se limita a crear una carpeta rara literalmente llamada `".."` dentro de la carpeta del mod, en vez de escapar de verdad fuera del árbol SAF. Aun así, **no es una garantía**, varía según el proveedor de almacenamiento del dispositivo, y es el tipo de cosa que conviene cerrar bien antes de un release "estable".

**Fix sugerido:** reemplazar el filtro por uno robusto:
```kotlin
private fun sanitizeEntryName(name: String): String {
    var sanitized = name.trim().replace("\\", "/").replace("\u0000", "")
    while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
    val parts = sanitized.split("/").filter { it.isNotEmpty() && it != "." && it != ".." }
    return parts.joinToString("/")
}
```
Esto rechaza explícitamente cualquier segmento `".."` en vez de intentar "limpiarlo" con reemplazos de texto. Aplica el mismo fix en los **dos** archivos (están duplicados literalmente).

---

### 2.4 Condición de carrera en `ThemeNotifier` / `LocaleNotifier`: la preferencia puede no guardarse y el usuario no se entera

**Archivo:** `lib/presentation/providers/theme_provider.dart`

```dart
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    Future.microtask(() => _loadSavedTheme());   // async, no se espera
    return ThemeMode.system;
  }

  late final Box<String> _box;   // se asigna dentro de _loadSavedTheme()

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _box.put('theme_mode', _themeModeToString(mode));   // ← puede no estar inicializado aún
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');   // ← fallo silencioso
    }
  }
}
```

`_box` es un campo `late final` que solo se asigna dentro de `_loadSavedTheme()`, la cual corre de forma asíncrona (`Future.microtask`) sin que nada bloquee la UI mientras tanto. Si el usuario toca el botón de tema (o el selector de idioma, mismo patrón en `LocaleNotifier`) **inmediatamente** después de abrir la app — antes de que `Hive.openBox` haya resuelto —, `_box.put(...)` lanza `LateInitializationError`, que cae en el `catch (e)` y solo hace `debugPrint`.

**Efecto para el usuario:** el tema cambia visualmente en esa sesión (el `state` sí se actualiza), pero la preferencia **no se persiste**. Al reabrir la app, vuelve al tema anterior — sin ningún mensaje de error, ninguna pista de por qué "no se guardó". Es exactamente el tipo de bug silencioso difícil de reproducir a propósito (solo pasa si tocas el toggle en la ventana de arranque).

**Fix sugerido:** abrir la Hive box de forma síncrona/esperada en el arranque de la app (en `main()`, junto al resto de la inicialización), o guardar la `Future<Box<String>>` y hacer `await` sobre ella en `setThemeMode`/`setLocale` en vez de asumir que `_box` ya existe.

---

### 2.5 `importFavourites` decodifica bytes con la función equivocada

**Archivo:** `lib/presentation/providers/mod_providers.dart`, línea 330

```dart
final bytes = result.files.first.bytes;
...
final raw = String.fromCharCodes(bytes);   // ← trata cada byte como code unit UTF-16
final decoded = jsonDecode(raw) as Map<String, dynamic>;
```

`String.fromCharCodes` interpreta cada entero de la lista como una unidad de código UTF-16, **no** como un byte UTF-8. Para JSON que solo contenga ASCII (probable, ya que son IDs de mods) esto funciona por casualidad. Pero si el archivo exportado alguna vez incluye texto no-ASCII (acentos, nombres de mods con caracteres especiales si cambia el formato de exportación a futuro), la decodificación produce texto corrupto y probablemente un error de `jsonDecode` reportado como "Import failed" sin explicación real.

**Fix:** usar `utf8.decode(bytes)` (ya está importado `dart:convert` en este archivo).

---

### 2.6 `_titleByModName` en `OverlayBridge` crece indefinidamente

**Archivo:** `lib/overlay/overlay_bridge.dart`, línea 14 y 71

```dart
static final Map<String, String> _titleByModName = {};
...
_titleByModName[modName] = modTitle;   // se agrega en cada descarga desde el overlay
```

Nunca se remueve una entrada de este mapa — ni al completar, ni al cancelar, ni al fallar una instalación. Para un uso normal de la app esto es un impacto marginal (mapa de strings pequeño), pero es una fuga de memoria real y acumulativa durante toda la vida del proceso, exactamente el patrón que pediste revisar.

**Fix sugerido:** en `_forwardEventToOverlay`, remover la entrada cuando el evento es `BgInstallCompleted`, `BgOperationCancelled` o `BgInstallError`.

---

### 2.7 Nombre de archivo sin extensión en el fallback de `DownloadUrlResolver`

**Archivo:** `lib/services/download_url_resolver.dart`, líneas 22-52

```dart
String _inferFileName(String url, String modTitle, {int? index}) {
  ...
  final base = sanitizeModTitle(modTitle);
  final safeName = base.isNotEmpty ? base : 'mod';
  final suffix = index != null && index > 1 ? '-$index' : '';
  return '$safeName$suffix';   // ← sin extensión, a diferencia de las otras 2 ramas de arriba
}
```

Las dos ramas anteriores de esta misma función sí garantizan una extensión válida (`.zip`, o la detectada en la URL). Pero el **último fallback** — cuando ni la URL ni el query param dan una pista de nombre — devuelve el nombre sin ninguna extensión. Esto puede llegar hasta `ModDownloadWorker.kt`, donde `isZipFile()` decide si tratar el archivo descargado como ZIP a extraer o como archivo suelto a copiar tal cual (`file.extension.equals("zip", ...)`) — un archivo sin extensión nunca calificará como ZIP y terminará copiado sin extraer, aunque en realidad sí sea un ZIP válido.

**Fix:** agregar `.zip` por defecto en esa última rama, igual que en la rama de arriba:
```dart
return '$safeName$suffix.zip';
```

---

## 3. Fallos silenciosos sin feedback al usuario (catch vacíos / genéricos)

Se encontraron **15 bloques `catch (_) {}`** (silenciosos, sin log ni mensaje) en todo el proyecto. La mayoría son razonables (limpieza de best-effort al borrar archivos temporales), pero algunos ocultan fallos que el usuario debería poder ver:

| Archivo | Línea | Qué se silencia | Riesgo |
|---|---|---|---|
| `lib/presentation/widgets/app_drawer.dart` | 884 (`_launch()`) | Falla de `launchUrl` al tocar un link social/externo | El usuario toca un botón (Discord, YouTube, Wiki, etc.) y **no pasa nada**, sin ningún snackbar de error. Parece que el botón está roto. |
| `lib/presentation/screens/settings_screen.dart` | 1340 | Falla al iniciar el overlay flotante (`FloatyChatheads.showChatHead`) o al pedir permisos | El spinner de carga simplemente se apaga sin decir por qué el overlay no se activó (falta permiso "dibujar sobre otras apps", por ejemplo). |
| `lib/presentation/screens/settings_screen.dart` | 412, 524 | Falla al chequear si hay carpeta de mods/DynOS seleccionada | Baja severidad — solo afecta el estado inicial del check visual, se puede reintentar manualmente. |
| `lib/presentation/screens/mod_detail_screen.dart` | 785 | Falla al parsear el nombre de archivo desde una URL (`_extractFilename`) | Bajo impacto, hay fallback (`url.split('/').last`). |
| `lib/data/datasource/*.dart` (5 archivos, ver sección 4) | 56, 143 (y equivalentes) | Falla al leer el JSON local descargado | Aceptable — cae al bundled de assets, es el comportamiento esperado documentado en el comentario. |

**Recomendación general:** para los dos primeros casos (links externos y overlay), agrega al menos un `AppSnackbar` de error usando el widget que ya existe en `lib/presentation/widgets/app_snackbar.dart` — ya tienes la infraestructura, solo falta conectarla ahí.

---

## 4. Duplicación estructural — 5 datasources casi idénticos

**Archivos:**
- `lib/data/datasource/local_mod_datasource.dart`
- `lib/data/datasource/vip_mod_datasource.dart`
- `lib/data/datasource/dynos_datasource.dart`
- `lib/data/datasource/touch_control_datasource.dart`
- `lib/data/datasource/omm_rebirth_datasource.dart`

Un `diff` entre ellos confirma que son **copy-paste** casi exacto (mismo flujo cache → JSON local → JSON bundled → fetch remoto → parseo), cambiando solo el nombre de la clase, la URL remota y la clave del JSON (`mods`, `vip_mods`, `dynos`, `touch_controls`, `omm_mods`). Esto significa:

- Los mismos bugs (como los `catch (_) {}` de la sección 3, o cualquier fix futuro a la lógica de cache/fetch) **hay que aplicarlos 5 veces**, y es fácil olvidar uno.
- Cualquier mejora futura (retry con backoff, validación de esquema más estricta, ETag/If-Modified-Since para no re-descargar si no cambió) también hay que repetirla 5 veces.

**Recomendación para 1.7.0 (refactor, no urgente pero de alto valor):** extraer una clase genérica, por ejemplo:

```dart
class RemoteJsonDatasource<T> {
  RemoteJsonDatasource({
    required this.remoteUrl,
    required this.assetPath,
    required this.localFileName,
    required this.jsonKey,
    required this.fromJson, // T Function(String id, Map<String, dynamic> json)
  });
  // ... misma lógica de _readRaw / fetchRemote / _parse, una sola vez
}
```
Y que cada datasource concreto sea solo una instancia parametrizada. Esto reduce ~700 líneas duplicadas a menos de 200.

---

## 5. Fuentes de verdad duplicadas / desincronizables

### 5.1 Número de versión hardcodeado en 3 lugares distintos

- `android/local.properties`: `flutter.versionName=1.6.2`
- `lib/core/constants/app_constants.dart`, línea 18: `static const String appVersion = '1.6.2';` — **usado directamente en la UI** (disclaimer, settings, drawer: `disclaimer_screen.dart:76,117,179`, `settings_screen.dart:106`, `app_drawer.dart:184`)
- `lib/services/update_service.dart`: ya obtiene la versión real e instalada dinámicamente vía `PackageInfo.fromPlatform()` (`UpdateService.currentVersion`)

El servicio de actualizaciones **ya resuelve correctamente** la versión real del paquete instalado en runtime, pero el resto de la UI usa la constante hardcodeada en su lugar. El día que se suba una build con un número de versión distinto en `pubspec.yaml`/Gradle y alguien olvide actualizar `AppConstants.appVersion`, la app mostrará una versión incorrecta en Ajustes/Disclaimer mientras el sistema de updates compara correctamente contra la real — un desfase silencioso y confuso.

**Fix sugerido:** reemplazar todos los usos de `AppConstants.appVersion` por `UpdateService.currentVersion` (ya inicializado en `main()` antes de `runApp`), y eliminar la constante duplicada.

### 5.2 URL del repo de GitHub hardcodeada en 4 lugares

- `lib/core/constants/app_constants.dart:22` → `githubReleasesUrl`
- `lib/services/update_service.dart:19` → `_githubApiUrl` (API, no la misma cadena)
- `lib/data/datasource/local_mod_datasource.dart:31` → `_remoteUrl` (raw.githubusercontent)
- `lib/widgets/update_dialog.dart:144` → literal inline `'https://github.com/retired64/sm64cdpy.releases/releases/latest'`

Si el repositorio de releases cambia de nombre/owner alguna vez, hay que tocar 4 archivos y es fácil dejar uno desactualizado. Vale la pena centralizarlo todo en `AppConstants` (ya casi todos están ahí salvo el de `update_dialog.dart`).

### 5.3 Constante muerta

`lib/core/constants/app_constants.dart:9` → `favoritesBoxKey = 'favorites'` (ortografía US) no se usa en ningún lado — la persistencia real de favoritos usa `favouritesKey` (ortografía UK, vía SharedPreferences, no Hive) definida en la línea 55. Es código muerto que puede confundir a quien lea el archivo pensando que favoritos vive en Hive. Se puede borrar directamente.

---

## 6. Otros hallazgos menores

- **`main.dart:32`** — `FileDownloader.setLogEnabled(true)` está activo incondicionalmente, también en builds de release (el comentario dice "Enable logs for debugging" pero no está condicionado a `kDebugMode`). No es grave, pero mete logs de la librería de descargas en producción sin necesidad.
- **`BackgroundInstallService.dispose()`** (`lib/services/background_install_service.dart:122-127`) nunca se invoca desde ningún lado del código — es un método público completo (cierra el stream, cancela la suscripción) que quedó sin uso. No hace daño estando ahí, pero es código muerto; o se conecta a un lifecycle real, o se elimina.
- **`ModInstallerPlugin.kt`** — `openDirectoryPicker` y `openDynosPicker` comparten el mismo campo `pendingResult`. Si llegaran a dispararse casi al mismo tiempo (doble tap rápido en dos flujos distintos, poco probable pero posible con dedos rápidos o testing automatizado), el segundo pisa al primero y el `Result` original del canal de método queda **sin resolver nunca** (el callback de Flutter que esperaba esa respuesta se queda colgado). Bajo riesgo pero fácil de blindar con un segundo campo separado por picker.
- Los boilerplate `// TODO: Specify your own unique Application ID` y `// TODO: Add your own signing config` en `android/app/build.gradle.kts` son comentarios por defecto que genera Flutter al crear el proyecto — ya están resueltos en la práctica (tienes `applicationId` y `signingConfig` reales), solo quedaron los comentarios. Cosmético, se pueden borrar para no confundir a futuros colaboradores.
- **`local_mod_datasource.dart:151`** (`hasLocalDb`) usa `file.existsSync()` (llamada síncrona/bloqueante) dentro de una función `async` que en el resto del archivo usa siempre las variantes async (`file.exists()`). Inconsistente, aunque de bajo impacto real (es un solo stat de archivo).

---

## 7. Cosas que están bien y no requieren tocarse

Vale la pena decirlo también: no encontré `TODO`/`FIXME` reales pendientes de trabajo inconcluso (solo coincidencias falsas con la palabra "TODO" en español dentro de cadenas de localización), no hay `print()` de debug olvidados (todo pasa por `debugPrint`, que se descarta en release), el manejo de Zip-slip aunque incompleto (sección 2.3) sí existe y está pensado, el flujo de descarga+instalación encadenada por WorkManager está bien diseñado con notificaciones foreground y cancelación, y la extracción de nombre de archivo desde `Content-Disposition` (RFC 5987 incluido) está implementada correctamente.

---

## 8. Checklist sugerido de parcheo → v1.7.0

Orden sugerido por impacto/esfuerzo:

- [ ] **(Seguridad)** Rotar/asegurar el keystore, no volver a incluir `key.properties` real en zips compartidos.
- [ ] **(Bloqueante)** Confirmar y adjuntar `pubspec.yaml` / `pubspec.lock` para poder verificar dependencias.
- [ ] **(2.1)** Invertir orden en `onDetachedFromActivity()` — limpiar observers antes de anular `activity`.
- [ ] **(2.3)** Reemplazar `sanitizeEntryName` en ambos archivos Kotlin por la versión basada en segmentos, no en `replace` de texto.
- [ ] **(2.4)** Corregir race condition de `_box` en `ThemeNotifier`/`LocaleNotifier`.
- [ ] **(2.2)** Soportar múltiples saltos de redirección en `ModDownloadWorker`.
- [ ] **(2.7)** Agregar `.zip` al fallback final de `_inferFileName`.
- [ ] **(2.5)** Cambiar `String.fromCharCodes` por `utf8.decode` en `importFavourites`.
- [ ] **(2.6)** Limpiar `_titleByModName` al finalizar/cancelar/fallar una instalación desde overlay.
- [ ] **(3)** Agregar feedback visible (snackbar) cuando falla `launchUrl` o el arranque del overlay.
- [ ] **(5.1)** Unificar el número de versión mostrado en UI con `UpdateService.currentVersion`.
- [ ] **(4)** Refactor de los 5 datasources a una clase genérica (puede ir en un ciclo posterior, no bloquea el release).
- [ ] **(5.2, 5.3, 6)** Limpieza de constantes muertas, URLs duplicadas y comentarios boilerplate.

Cuando quieras, puedo ayudarte a implementar cualquiera de estos parches directamente sobre el código (empezando por los de seguridad/bloqueantes), o generar un diff/PR por cada punto del checklist.
