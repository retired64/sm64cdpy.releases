# AGENTS.md — Reglas permanentes de desarrollo de SM64CDPY

Esta guía es obligatoria para cualquier persona o IA que modifique el
repositorio. Léela completa antes de actuar. Su propósito es conservar el
contexto técnico y de producto, evitar soluciones parciales y mantener un flujo
coherente entre Flutter, Android nativo, WorkManager y la burbuja flotante.

No des por terminada una tarea por corregir una sola pantalla: completa el
flujo vertical y revisa sus implementaciones hermanas.

## 1. Producto y alcance

SM64CDPY es una aplicación Android de catálogo, descarga e instalación de mods.
La experiencia debe ser comprensible sin conocer SAF, WorkManager, engines,
ZIP, rutas o errores de plataforma.

Incluye catálogo general, VIP, DynOS, Touch Controls, OMM Rebirth, Render96,
favoritos, instalación manual/automática, burbuja flotante y actualización OTA
desde GitHub Releases. Touch Controls usa la misma carpeta de DynOS.

El producto apunta a teléfonos Android. No amplíes el alcance a iOS, web o
escritorio salvo petición explícita.

## 2. Documentación y contenido fuera de alcance

- `README.md` es el README canónico y permanece en inglés.
- `README_ES.md` y `README_PT.md` son las versiones en español y portugués
  brasileño.
- `docs/README.md` indexa la documentación activa.
- `docs/ARCHITECTURE.md`, `docs/DOWNLOADS_AND_OVERLAY.md`,
  `docs/PROJECT_STATUS.md` y `docs/CI_CD.md` describen el estado vigente.
- `docs/SM64CDPY-v1.7.0-TASK-CHECKLIST.md` es el checklist operativo actual.
- Documentación retirada va a `docs/archive/`; no se mezcla con la vigente.

Repositorios/carpetas de ejemplo como Konami/Komi Store,
`floating-apps-examples`, `run-actions-github` y demás material clonado no son
parte del producto. No los integres, publiques ni trates como fuente de
SM64CDPY. Antes de cambiar `.gitignore`, confirma que siguen excluidos.

## 3. Arquitectura que debe preservarse

### Flutter

- `lib/core`: constantes, tema, router y utilidades transversales.
- `lib/domain`: entidades y contratos de dominio.
- `lib/data`: fuentes y repositorios.
- `lib/services`: plataforma, descargas, instalación y OTA.
- `lib/presentation/providers`: estado observable.
- `lib/presentation/screens`: pantallas y flujos de usuario.
- `lib/presentation/widgets`: componentes y coordinadores globales.
- `lib/overlay`: panel y bridge de la burbuja.
- `lib/l10n`: ARB y archivos generados.

No pongas lógica de WorkManager o persistencia dentro de tarjetas visuales. La
UI representa estado y solicita acciones; servicios/providers coordinan.

### Android nativo

- `ModInstallerPlugin.kt`: MethodChannel/EventChannel, SAF y WorkManager.
- `ModDownloadWorker.kt`: descarga, progreso, reintentos y temporales.
- `ModInstallWorker.kt`: copia/extracción SAF, progreso y resultado.
- `SafZipExtractor.kt`: implementación compartida ZIP/7z/SAF.

No dupliques extracción o escritura SAF si puede reutilizarse
`SafZipExtractor`.

### Dos engines independientes

Existen el engine principal y el engine del overlay. No comparten memoria,
providers, singletons ni variables estáticas. Un dato entre engines debe viajar
por mensajes de `floaty_chatheads`, SharedPreferences cuando sea seguro,
MethodChannel/EventChannel, WorkManager o almacenamiento nativo. Nunca intentes
sincronizarlos mediante una variable estática.

## 4. Flujo profesional de descarga e instalación

Toda operación automática sigue esta máquina de estados conceptual:

```text
requested
  -> pending / waitingForNetwork
  -> downloading
  -> installing
  -> completed | failed | cancelling -> cancelled
```

Reglas obligatorias:

1. Encolar un Worker no significa instalación completa.
2. 100 % descargado no significa instalación completa.
3. Solo `install_completed`/`SUCCEEDED` permite mostrar éxito final.
4. Error y cancelación son terminales y liberan la UI.
5. `pending` sigue siendo una operación activa.
6. Tras reiniciar, reconcilia el estado persistido con WorkManager.
7. Si un UUID guardado ya no existe, elimina el estado obsoleto.
8. Al recrear el engine, vuelve a observar Workers activos.
9. Una rotación no debe desconectar observers si el engine sobrevive.

### Fuentes de verdad

- WorkManager es autoridad sobre trabajos activos.
- SharedPreferences guarda metadata de recuperación: clave, UUID de descarga,
  UUID de instalación, título y destino.
- `BackgroundInstallService._infoMap` es cache/proyección en memoria.
- `bgInstallStateProvider` es la proyección observable para Flutter.
- El overlay recibe su proyección mediante `OverlayBridge`.

Si difieren, reconcilia desde WorkManager y propaga. Una tarjeta nunca es
fuente de verdad.

### Contrato de eventos

Si Kotlin cambia un evento, revisa a la vez: emisor nativo, parser de
`BackgroundInstallService`, `BgInstallEvent/BgInstallInfo`, provider Riverpod,
coordinador global, bridge/panel y pantallas.

Los eventos vigentes incluyen `pending`, `download_progress`,
`download_completed`, `install_progress`, `install_completed`, `error` y
`cancelled`, además de legacy soportados. Ningún evento emitido queda sin
consumidor. Una actualización de progreso debe preservar `displayTitle`, UUIDs,
destino y demás metadata de identidad.

## 5. Identidad, paralelismo y temporales

El título visible nunca es la única identidad. Usa una clave estable como:

```text
section + contentId + fileId
```

App y overlay deben generar la misma clave para el mismo contenido. El título
es presentación, no identidad.

Para recursos paralelos:

- unique work y tags derivan de la clave canónica;
- descarga, instalación y cadena identifican la misma operación;
- cada Worker usa notificación derivada de su UUID;
- cada descarga usa directorio temporal aislado por UUID;
- dos `mod.zip` nunca comparten ruta;
- repetir la misma operación puede usar `REPLACE` intencionalmente;
- operaciones diferentes avanzan en paralelo sin sobrescribirse.

Después de tocar IDs, considera: doble toque, igual título, igual filename, dos
mods simultáneos, cancelar uno y la misma operación iniciada desde app/overlay.

## 6. Ajustes, SAF y auto-install

`auto_install_mods` es global y SharedPreferences es su fuente persistente. Si
un lector la cachea, todos los escritores refrescan ese cache. Caso canónico:
el toggle de Ajustes debe llamar `OverlayBridge.refreshAutoInstall()`.

### Auto-install activado

- Comprueba antes la carpeta correcta.
- General/VIP/Render96/OMM normal usan carpeta de mods.
- DynOS, Touch Controls y OMM marcado DynOS usan carpeta DynOS compartida.
- Descarga e instala por WorkManager.
- Muestra progreso real y resultado final.

### Auto-install desactivado

- Descarga sin afirmar que instaló.
- Si ofrece instalación manual, pide confirmación al terminar.
- Si falta carpeta, ofrece Ajustes y comunica “descargado, no instalado”.

### SAF

- Verifica que la URI guardada siga accesible.
- Si se revocó, limpia selección inválida y pide elegir de nuevo.
- Nunca muestres éxito antes de confirmar copia/extracción.
- Limpia temporales tras éxito, fallo terminal o cancelación cuando sea seguro.

## 7. Cancelación

Cancelar no es enviar una orden y asumir éxito.

- Flutter espera confirmación nativa de WorkManager.
- Mientras tanto usa `cancelling` y bloquea acciones incompatibles.
- Publica `cancelled` solo después de confirmar.
- Si falla, restaura un estado accionable y muestra error.
- Cancela tags de descarga, instalación y cadena de la misma clave.
- Ignora progreso antiguo en vuelo sin ocultar el final confirmado.

## 8. Feedback y experiencia de usuario

- Progreso local: tarjeta/botón correspondiente.
- Resultado terminal: coordinador global, aunque se cambie de pantalla.
- En background/cerrada: feedback por notificación cuando haya permiso.
- No dupliques snackbars locales/globales para el mismo resultado.
- Convierte fallos en mensajes accionables: 404, red, carpeta, permiso SAF,
  archivo corrupto o instalación fallida.
- Conserva detalle técnico con acción Copiar, no como mensaje principal.
- Nunca muestres `PlatformException(... null)` como explicación al usuario.
- Usa `try/finally` para que una excepción previa al enqueue no congele botones.
- Bloquea dobles toques durante pending/download/install/cancelling.

## 9. Checklist obligatorio de estado compartido

Al tocar una preferencia, cache, provider, evento, ID o estado leído desde más
de un lugar:

1. **Busca todos los escritores y lectores** con `rg` en todo el proyecto.
2. **Define la fuente de verdad** y qué gana en caso de conflicto.
3. **Revisa caches:** cada cache necesita invalidación/reconciliación o una
   justificación explícita.
4. **Revisa ambos engines:** dónde vive el dato y cómo cruza.
5. **Revisa ciclo de vida:** background, cierre, reapertura, rotación y muerte
   del proceso.
6. **Revisa paralelismo:** IDs, tags, rutas, nombres y notificaciones.
7. **Revisa Futures sin `await`:** usa `unawaited(...)` solo intencionalmente,
   capturando errores dentro del Future.
8. **Busca hermanos:** DynOS, Touch Controls, OMM, VIP, Render96, detalle y
   overlay según aplique.
9. **Sigue eventos de extremo a extremo:** emisor, parser, provider, bridge,
   UI y final.
10. **Verifica limpieza:** persistencia, observers, subscriptions, timers,
    temporales y notificaciones.

El resumen final de estas tareas incluye una sección titulada exactamente
**“Verificación de sincronización de estado”** que responda:

- quién escribe y quién lee;
- cuál es la fuente de verdad;
- si todo quedó sincronizado;
- caches nuevos y quién los invalida;
- Futures intencionalmente no esperados;
- implementaciones hermanas revisadas.

## 10. Async y ciclo de vida

- Espera Futures que cambien estado o determinan lo que ve el usuario.
- No uses `.then(...)` para ocultar errores que deberían esperarse.
- Cancela StreamSubscriptions en `dispose`/owner teardown.
- Retira `observeForever` al terminar el Worker o destruir el plugin.
- No retires observers por una rotación si plugin/engine sobrevive.
- Cancela timers o justifica su vida independiente.
- Tras cada `await` en un State, revisa `mounted` antes de `context/setState`.
- Un callback síncrono puede usar `unawaited`, pero el Future captura errores.

## 11. Localización

Toda cadena nueva visible debe estar en `app_en.arb`, `app_es.arb`,
`app_es_419.arb`, `app_pt.arb` y `app_pt_BR.arb`. Después ejecuta
`flutter gen-l10n`. No edites Dart generado manualmente.

Inglés es referencia semántica. Español y portugués expresan la misma acción de
forma natural, no una traducción técnica confusa. Strings nativos de
notificación se mantienen en `values`, `values-es` y `values-pt-rBR`.

## 12. Red, archivos y errores

- Resuelve URLs indirectas con `DownloadUrlResolver` antes del Worker.
- Sigue redirects con límite.
- 4xx son permanentes; no reintentes un 404.
- Fallos transitorios usan reintentos acotados.
- Con `Content-Length`, detecta descarga truncada.
- No confíes solo en extensión; conserva validación ZIP/7z/archivo suelto.
- No registres secretos o credenciales.

## 13. Documentación, versión y GitHub Actions

Si cambia comportamiento, arquitectura, CI o limitaciones, actualiza changelog,
checklist y documento técnico; README solo si cambia información pública.

Toolchain actual: Flutter `3.41.7`, Dart `3.11.x`, Java 17. Si cambia, alinea
ambos workflows, los tres README, `docs/CI_CD.md` y checklist.

- `buildAndroid-testing.yml`: análisis y APK arm64 de prueba.
- `buildAndroid.yaml`: build firmado/publicación manual y pre-release.

No publiques releases, tags o assets sin autorización explícita.

## 14. Forma de trabajar

Antes de modificar:

1. lee este archivo completo;
2. inspecciona `git status --short` y conserva cambios del usuario;
3. lee documentación relacionada;
4. busca call sites y patrones hermanos con `rg`;
5. define flujo completo y estados terminales.

Durante la implementación:

- completa el flujo, no un parche aislado;
- reutiliza servicios/helpers/widgets;
- evita lógica duplicada entre pantallas;
- preserva compatibilidad con estado persistido cuando sea razonable;
- no reformatees archivos no relacionados;
- no modifiques ejemplos/archivo histórico salvo que se pida;
- no sobrescribas trabajo ajeno ni uses Git destructivo.

Si descubres una inconsistencia hermana directamente relacionada, corrígela o
explica por qué queda fuera de alcance; no la ignores.

## 15. Validación mínima

Flutter/Dart:

```bash
dart format <archivos modificados>
flutter analyze lib
```

Si cambias ARB:

```bash
flutter gen-l10n
flutter analyze lib
```

Si cambias Kotlin, recursos, MethodChannel o Workers:

```bash
android/gradlew -p android :app:compileDebugKotlin
```

Siempre:

```bash
git diff --check
```

Ejecuta tests existentes cuando apliquen. Si no existen o hace falta dispositivo,
dilo explícitamente: análisis estático no equivale a prueba funcional.

Matriz manual para descarga/instalación:

- auto-install on/off;
- carpeta presente/ausente/permiso revocado;
- éxito, 404, pérdida y recuperación de red;
- cambiar pantalla, rotar, minimizar, cerrar y reabrir;
- cancelar durante descarga e instalación;
- iniciar desde app y overlay;
- dos operaciones paralelas y mismo filename;
- Android 13+ con notificaciones permitidas/denegadas.

## 16. Definición de terminado

Una tarea solo está terminada cuando:

- flujo feliz, error, cancelación y falta de configuración tienen salida;
- no hay éxito falso ni loading permanente;
- navegación, rotación, background y restauración fueron considerados;
- app y overlay usan identidad/destino coherentes;
- no hay colisiones de Workers, archivos o notificaciones;
- strings y documentación están sincronizados;
- se revisaron implementaciones hermanas;
- pasaron validaciones aplicables;
- se declararon pruebas físicas pendientes;
- el resumen explica resultados, no solo archivos;
- si hubo estado compartido, incluye “Verificación de sincronización de estado”.

El criterio final es sencillo: el usuario debe entender qué ocurre, qué terminó,
qué falló y qué puede hacer después sin conocer la implementación técnica.
