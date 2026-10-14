# Task Checklist Manager — SM64CDPY v1.7.0

> Incremental stabilization and pre-release plan for `1.7.0+18`.

| Field | Value |
|---|---|
| Project | SM64CDPY — SM64CoopDX Mods Browser |
| Target version | 1.7.0+18 |
| Intended channel | GitHub pre-release |
| Platform | Android 7.0+ (`minSdk 24`) |
| Checklist created | 2026-09-20 |
| Current phase | Stabilization and validation |
| Release owner | Retired64 |

## How to use this checklist

- Complete tasks in priority order when possible.
- Add the test date, device, Android version and result next to every manual test.
- Do not mark a group complete because the feature exists in code; mark it only after verification.
- Record bugs under **Findings and decisions** and link the issue or commit when available.
- A failed optional item does not necessarily block a pre-release. Every item marked **release gate** does.

## Current assessment

| Area | Score | Assessment |
|---|---:|---|
| Product and concept | 8.5/10 | Useful mobile companion with a distinctive overlay concept |
| Architecture | 7.5/10 | Sound Flutter/Kotlin split; state recovery still needs consolidation |
| Functional implementation | 7.5/10 | The difficult download/install pipeline is present |
| Verifiable quality | 5/10 | No automated test suite or recorded device matrix yet |
| Maintainability | 7/10 | Navigable code and clean canonical static analysis |
| Stable-release readiness | 6/10 | Suitable for pre-release after the release gates below |
| Overall | **7.2/10** | Promising and worth continuing; stabilize before expanding scope |

## Confirmed implementation baseline

- [x] Main and auxiliary JSON catalogues exist.
- [x] Search, filters, sorting, pagination and favourites exist.
- [x] English, Spanish and Brazilian Portuguese localization exists.
- [x] SAF folder selection and persisted Android permissions exist.
- [x] WorkManager download → install chains exist.
- [x] Foreground notifications, progress and cancellation exist.
- [x] ZIP, 7z and standalone file handling exists.
- [x] GitHub Release URL resolution and OTA update flow exist.
- [x] The floating overlay and main-engine bridge exist.
- [x] Main catalogue detail and overlay share one canonical latest-version resolver.
- [x] Previous releases open progressively in a virtualized Android bottom sheet.
- [x] Installation results use a visible notification channel and a user-facing mod title.
- [x] DynOS and Touch Controls share one destination and respect the global auto-install preference in the drawer flow.
- [x] DynOS and Touch Controls use friendly download errors while retaining copyable technical details.
- [x] Root screens use a pinned shared app bar so the navigation drawer remains reachable while scrolling, loading or showing an error.
- [x] Catalogue category and sort controls live in the catalogue rather than being duplicated in global navigation.
- [x] `flutter analyze lib` completed with no issues on 2026-09-20.
- [ ] Verify every item above at runtime on a clean physical device.

## P0 — Pre-release gates

These items should be completed before publishing `v1.7.0` as a GitHub pre-release.

### Reproducible environment

- [ ] Decide the single Flutter version for local development and GitHub Actions.
  - Repository/workflows now declare Flutter `3.41.7`.
  - The environment used during the documentation audit reported Flutter `3.38.7`.
  - Do not change CI blindly: first run a clean successful build with the chosen version.
- [ ] Pin the chosen Flutter version consistently in both workflows and documentation.
- [ ] Confirm Java 17 and the Android SDK/NDK versions used by the successful build.
- [ ] Run `flutter clean` followed by `flutter pub get`.
- [ ] Run `flutter analyze lib` successfully.
- [ ] Produce a signed arm64 release APK.
- [ ] Install the signed APK on a physical device.
- [ ] Record the exact tool versions and build date below.

Environment record:

```text
Flutter:
Dart:
Java:
Android SDK:
NDK:
Host OS:
Build date:
Result:
```

### Core smoke test — release gate

- [ ] Clean installation opens without crashing.
- [ ] Bundled catalogue loads without a network connection.
- [ ] Remote database refresh succeeds.
- [ ] Search, category filters, ordering and pagination work.
- [ ] Scroll every root section in both directions and confirm the drawer button remains visible and responds to the first tap.
- [ ] Open the drawer by button, edge swipe and Android Back; confirm each interaction closes or opens it once without stale animation.
- [ ] A favourite survives closing and reopening the app.
- [ ] Favourite export and import work with UTF-8 content.
- [ ] Theme selection survives restart.
- [ ] EN, ES and PT-BR selection survives restart.
- [ ] The app detects and launches SM64CoopDX when installed.
- [ ] The missing-game path provides understandable feedback.

### Download and installation — release gate

- [ ] Select the normal mods destination through SAF.
- [ ] Select the DynOS/Touch Controls destination through SAF.
- [ ] Download and install one ZIP successfully.
- [ ] Download and install one 7z successfully.
- [ ] Download and copy one standalone Lua or other supported file.
- [ ] Progress changes during both download and extraction.
- [ ] Completion is shown in the app and notification.
- [ ] Confirm the completion notification produces a heads-up alert when the new results channel is enabled.
- [ ] Confirm the notification shows the mod title instead of its internal operation key.
- [ ] Cancel an active download from the app.
- [ ] Cancel an active operation from the notification.
- [ ] Confirm a failed URL produces an error instead of an infinite spinner.
- [ ] Confirm a denied notification permission does not crash the operation.
- [ ] Revoke the SAF permission and confirm the app requests folder selection again.

### Overlay — release gate

- [ ] Grant overlay permission and open the bubble.
- [ ] Deny overlay permission and verify useful feedback.
- [ ] Open and close the bubble repeatedly without freezing either engine.
- [ ] Search and change overlay sections.
- [ ] Start a download from the overlay.
- [ ] Confirm a multi-version mod downloads its newest available release from the overlay.
- [ ] Confirm a newest release with multiple files opens the compact file selector.
- [ ] Receive live download and installation progress in the overlay.
- [ ] Cancel from the overlay.
- [ ] Close and reopen the panel during an active operation.
- [ ] Toggle auto-install in Settings and confirm the bridge immediately uses the new value.
- [ ] Keep the game open while the overlay operates.
- [ ] Document any engine/process recreation failure as a known pre-release limitation.

### GitHub pre-release pipeline — release gate

- [ ] Confirm `pubspec.yaml` contains the intended `versionName` and `versionCode`.
- [ ] Confirm the matching entry exists in `changelog_screen.dart`.
- [ ] Confirm `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD` and `KEY_ALIAS` secrets.
- [ ] Run `buildAndroid-testing.yml` successfully first.
- [ ] Download and install its arm64 artifact.
- [ ] Run `buildAndroid.yaml` with `prerelease: true`.
- [ ] Confirm arm64, arm32 and x86_64 assets are attached.
- [ ] Confirm filenames are recognized by `UpdateConfig`.
- [ ] Confirm release notes and SHA-256 hashes are present.
- [ ] Confirm the pre-release is not incorrectly marked as latest stable.
- [ ] Test the OTA check against the published pre-release behavior and document the result.

## P1 — Stabilization work

### WorkManager as the source of truth

- [x] Reconcile restored `BackgroundInstallService._infoMap` entries with actual WorkManager state.
- [x] Remove or correct stale active entries after process death.
- [x] Define behavior when the stored Work UUID no longer exists.
- [x] Restore download and installation progress after reopening the app where possible.
- [ ] Add a test for RUNNING, ENQUEUED, SUCCEEDED, FAILED and CANCELLED restoration.

### Unique identities and parallel operations

- [x] Stop using sanitized display titles as the only work identity.
- [x] Define an operation key such as `section + modId + fileId`.
- [x] Derive temporary filenames/directories, unique work names and notification IDs from an operation/Worker identity.
- [ ] Test two different mods whose titles sanitize to the same value.
- [ ] Test two different mods in parallel.
- [ ] Test a repeated tap on the same mod and confirm intentional replacement.
- [ ] Confirm download and install notifications cannot collide across active operations.

### Async persistence and cancellation

- [x] Replace or explicitly document the fire-and-forget persistence in `_persistToPrefs()`.
- [x] Ensure asynchronous SharedPreferences failures are contained without escaping the event listener.
- [x] Make `cancelMod()` await native WorkManager cancellation.
- [x] Avoid showing a final cancelled state before native cancellation is confirmed.
- [ ] Review every unawaited Future in download, overlay and persistence paths.

### Favourites initialization

- [ ] Remove the race between the initial SharedPreferences read and an immediate favourite toggle.
- [ ] Represent loading explicitly or await initialization before mutation.
- [ ] Add tests for toggle-before-load, import, export and restart.

### Locale synchronization

- [ ] Decide whether the overlay follows the device locale or the app-selected locale.
- [ ] If it follows the device, remove the unused `app_locale` mirror.
- [ ] If it follows the app, send the selected locale through the engine bridge and apply it safely.
- [ ] Identify every writer and reader before changing this shared value.
- [ ] Test locale changes while the overlay is open.

## P1 — Required test matrix

| Android | Device/emulator | Focus | Result | Date |
|---|---|---|---|---|
| 7 / API 24 |  | Minimum supported SDK | ⬜ |  |
| 10 / API 29 |  | Legacy/scoped storage boundary | ⬜ |  |
| 12 / API 31 |  | Background execution restrictions | ⬜ |  |
| 13 / API 33 |  | Notification permission | ⬜ |  |
| 14 / API 34 |  | Foreground service dataSync type | ⬜ |  |
| 15 |  | Modern lifecycle/storage behavior | ⬜ |  |
| 16 |  | Latest behavior and orientation limitations | ⬜ |  |

ABI checks:

- [ ] arm64-v8a physical device.
- [ ] armeabi-v7a build/install validation.
- [ ] x86_64 emulator validation.
- [ ] OTA asset selection for each ABI.

Network and file checks:

- [ ] Direct file URL.
- [ ] Multiple HTTP redirects.
- [ ] GitHub latest release URL.
- [ ] GitHub tagged release URL.
- [ ] HTTP 403, 404 and 410.
- [ ] Timeout or disconnected network.
- [ ] Response without `Content-Length`.
- [ ] Truncated response.
- [ ] Corrupted ZIP.
- [ ] Corrupted 7z.
- [ ] Archive with unsafe `../` path segments.
- [ ] Device with insufficient free storage.

Lifecycle checks:

- [ ] App moved to background during download.
- [ ] App process terminated during download.
- [ ] App process terminated during installation.
- [ ] Device reboot with queued/running work.
- [ ] Overlay engine closed while main engine stays alive.
- [ ] Main activity recreated while overlay stays visible.
- [ ] SAF permission revoked after selection.
- [ ] Notification permission revoked after first launch.

## P2 — Automated tests

- [ ] Create the initial `test/` directory and test conventions.
- [ ] Test `sanitizeModTitle` and collision cases.
- [ ] Test OTA semantic version comparison.
- [ ] Test ABI-specific APK selection.
- [ ] Test GitHub download URL resolution.
- [ ] Test each JSON catalogue parser with valid and malformed fixtures.
- [ ] Test favourites UTF-8 import/export.
- [ ] Test native event → `BgInstallInfo` state transitions.
- [ ] Test persisted install-state serialization and restoration.
- [ ] Test safe archive-path normalization.
- [ ] Test overlay states: pending, progress, error, cancelled and completed.
- [ ] Add MethodChannel/EventChannel fakes for integration-oriented service tests.
- [ ] Add at least one automated application smoke test.

## P2 — CI/CD improvements

- [ ] Add a `pull_request` validation workflow.
- [ ] Run `flutter analyze lib` or ensure ignored local reference repos cannot enter analysis scope.
- [ ] Run the automated test suite once it exists.
- [ ] Add an arm64 build check for pull requests or the main branch.
- [ ] Fix the release message that says only `versionCode` must change when an existing tag actually requires a new `versionName`.
- [ ] Validate that the Dart changelog parser found the requested version before publishing.
- [ ] Consider pinning third-party GitHub Actions to immutable commit SHAs.
- [ ] Decide whether the hard-coded Discord role ID belongs in repository configuration or a variable/secret.
- [ ] Confirm keystore cleanup runs after every failure path.

## P2 — Diagnostics and installation records

- [ ] Design an install record containing mod ID, version, source URL, destination, date and copied files.
- [ ] Persist successful install records independently from transient progress events.
- [ ] Add an installation/download queue screen backed by durable state.
- [ ] Add retry, cancel and clear-history actions.
- [ ] Add an exportable diagnostic report with app version, Android version, ABI, permissions and recent non-sensitive errors.
- [ ] Avoid exporting personal paths, tokens, webhook URLs or complete private URIs.
- [ ] Add preflight checks for available storage and current SAF access.

## P3 — Feature ideas after stabilization

- [ ] Installed-mod history.
- [ ] Mod update detection using installed version records.
- [ ] Repair or reinstall an existing mod.
- [ ] Safe uninstall based only on recorded files owned by that installation.
- [ ] Compatibility metadata and warnings.
- [ ] Improved overlay recovery and active-download summary/badge.
- [ ] Better download provenance and checksum verification when the source provides hashes.

Defer until the core is stable:

- [ ] Accounts or cloud synchronization.
- [ ] Social features or comments.
- [ ] A proprietary marketplace/backend.
- [ ] Automatic bulk downloads.
- [ ] Additional desktop/mobile platforms.
- [ ] Large architectural or visual rewrites without a concrete defect.

## Pre-release acceptance criteria

The current version may be published as a pre-release when:

- [ ] Every P0 release gate has passed or has a clearly documented known limitation.
- [ ] The app builds reproducibly with one declared Flutter version.
- [ ] At least one physical arm64 device passes the complete smoke test.
- [ ] ZIP, 7z and standalone installation each pass once.
- [ ] Download failure and cancellation provide visible feedback.
- [ ] The overlay completes one end-to-end installation or its limitation is prominently included in release notes.
- [ ] No known issue risks writing outside the selected SAF tree.
- [ ] Release assets, filenames and SHA-256 hashes are correct.
- [ ] The release is marked **pre-release**, not stable/latest.

## Stable-release acceptance criteria

Do not promote the version to stable until:

- [ ] WorkManager state is reconciled after process death.
- [ ] Parallel operations and identity collisions have been tested.
- [ ] The representative Android matrix has no unresolved critical failures.
- [ ] A minimum automated test suite covers parsing, state transitions, URL resolution and OTA selection.
- [ ] Known limitations are documented and acceptable.

## Findings and decisions log

Use this section as the checklist is executed.

| Date | Area | Finding or decision | Status / link |
|---|---|---|---|
| 2026-09-20 | Static analysis | `flutter analyze lib` passed with no issues | Confirmed |
| 2026-09-20 | Local workspace | Root analysis includes ignored example repositories and reports unrelated issues | Use canonical source scope |
| 2026-09-20 | Toolchain | Repository and workflows aligned to Flutter 3.41.7 | Updated; verify the release build in GitHub Actions |
| 2026-09-20 | Tests | No `test/` or `integration_test/` suite exists | Open |
| 2026-09-20 | Release plan | Publish current 1.7.0 as a GitHub pre-release after P0 gates | Decided |
| 2026-09-20 | DynOS / Touch Controls | Unified automatic WorkManager flow, manual post-download confirmation, shared-folder wording, background card progress and friendly 404 handling; the DynOS-targeted OMM sibling was aligned too | Implemented; runtime test pending |

## Notes

- Keep Komi Store, Floating Apps examples, `run-actions-github`, and other cloned references local and ignored. They are research material, not project modules.
- Before changing any shared preference, cached flag, Worker identity or notification ID, follow the synchronization checklist in `AGENTS.md`.
- Record every intentional fire-and-forget Future in the corresponding change summary.

## Integración de temas — custom-themes (2026-10-13)

- [x] Crear rama local desde main y descartar trabajo de flutter-termux solicitado.
- [x] Implementar contrato/catálogo y definiciones incluidas.
- [x] Conectar selección y modo independientes con un escritor Hive confirmado.
- [x] Revisar las 14 pantallas, widgets y raíz compartida del overlay fijo.
- [x] Añadir claves ARB EN/ES/es_419/PT/pt_BR sin editar generados manualmente.
- [x] Preparar pruebas de tokens, persistencia/error/paralelismo y selector.
- [x] Preparar generación/formato/tests y parche de fuentes en Actions.
- [x] Documentar flujo, inventario de cada Dart y sincronización de estado.
- [x] Ejecutar diff-check y comprobaciones JSON/YAML/contraste locales.
- [ ] Ejecutar Actions: gen-l10n, dart format, analyze, tests y APK arm64.
- [ ] Revisar/incorporar parche generado por el runner si corresponde.
- [ ] Completar matriz física de temas, operaciones en curso y overlay fijo.

No se instaló SDK ni se afirmó compilación local. Registro de cambios de
esta rama y guía: [cuatom_themea.md](../cuatom_themea.md). La versión/manifiestos
publicados permanecen sin cambios.

### Primera build de custom-themes — corrección del análisis

El log recibido detuvo `flutter analyze` por un inicializador autorreferente
(`final retro = retro`) en Home. Corregido a `RetroTheme.of(context)` y revisado
el mismo patrón en todos los Dart de lib/test. La nueva ejecución de Actions,
tests y APK sigue pendiente; no se marca el release gate como completado.

### Build #173 — regresión de decoración

Análisis sin incidencias, 63 tests aprobados y una prueba de decoración fallida.
Se corrigió el harness para esperar frames pendientes y limitar los finders a
los componentes examinados; se añadió cobertura de los tres diseños sin manga
y retorno a Retro. Testing adjunta ahora el log expandido de pruebas, conserva
el exit code y no permite construir APK si los tests fallan. Pendiente repetir
Actions: el resumen recibido no muestra la excepción/assertion original.

### Simplificación de temas y coherencia de Ajustes

El usuario confirmó la prueba anterior como funcional. Se retiraron Odyssey y
GameCube del enum, catálogo, definiciones y ARB. Los IDs persistidos retirados
recuperan Retro Manga sin perder modo; su siguiente confirmación guarda el ID
válido incluso si visualmente ya coincide con el fallback.

Tema de interfaz y modo usan el mismo componente expandible y opciones con
marca de selección. Se adaptaron pruebas de persistencia, decoración y UI para
los dos diseños y abrir/cerrar/cambiar modo. Pendiente nueva ejecución de Actions
y revisión física de este ajuste; no se modificó overlay ni Android nativo.

### Idioma y superficies de Ajustes Mario 64

- [x] Reutilizar encabezado y opciones en tema, modo e idioma.
- [x] Conservar giro 200 ms y expansión 220 ms del selector de idioma.
- [x] Esperar setter existente y bloquear doble toque hasta finalizar.
- [x] Aplicar suavizado local de tarjetas, diálogos, iconos y switches Mario.
- [x] Mantener Retro y los flujos de SAF/WorkManager/overlay.
- [x] Preparar prueba de UI de idioma y réplica de preferencias.
- [ ] Ejecutar nueva Actions y verificar idioma/texto grande en dispositivo.

## Preparación de versión oficial 1.8.3+22

- [x] Confirmar éxito de Actions #177 para la base de idioma/Ajustes.
- [x] Incrementar pubspec a 1.8.3+22; conservar versionCodes ABI derivados.
- [x] Crear manifiesto canónico EN/ES/PT-BR con actualización opcional.
- [x] Adaptar test de manifiesto actual para leer versión desde pubspec.
- [x] Validar manifiestos y renderer con los tests Python disponibles.
- [x] Alinear README, arquitectura, estado, CI/CD y guía de release.
- [x] Testing: validación de versión/notas, previews y opción manual todas ABI.
- [x] Release: stable solo en main y target_commitish sobre SHA construido.
- [ ] Nueva Actions con build 22 aprobada.
- [ ] Prueba física, tres ABI y recuperación/OTA desde 1.8.2.
- [ ] Fijar publishedAt definitivo (el valor actual es provisional).
- [ ] Autorizar y realizar merge a main; todavía no realizado.
- [ ] Autorizar publicación y comprobar tag/assets/Discord/sitio; no iniciado.

Fuente canónica: `release-manifests/v1.8.3.json`. Plan completo:
[RELEASE_1.8.3.md](RELEASE_1.8.3.md). No se modifican releases históricas.

## Activación de mods — candidata 1.8.3

Biblioteca incluye una sección de unidades Lua del juego con switches de selección
para el próximo inicio. SAF autoriza `user`; el servicio nativo conserva ajustes,
comprueba identidades/incompatibilidades/tamaño, crea respaldo y verifica la escritura.
DynOS/Touch mantienen su contrato separado. La validación física está pendiente.
Plan, archivos, estados y matriz: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md).
Ambos workflows ejecutan también `:app:testReleaseUnitTest`. No hay merge ni release.

Biblioteca integra Mods del juego como pestaña nativa del sistema visual, con
búsqueda y filtros locales, contador de activados, tarjetas adaptadas a cada
diseño y confirmación de juego cerrado por visita (reiniciada al reanudar).
Restaurar continúa exigiendo confirmación; cada escritura conserva la autoridad
nativa. Ver [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md), integración visual.

Mods del juego absorbe los datos útiles de Detectados: autor, categoría, versión
informativa y descripción con detalles/búsqueda. Detectados ya no es una pestaña.
La enumeración y los switches siguen las reglas del juego; no hay coincidencias
por título ni otro escaneo automático de descubrimiento. Ver GAME_MOD_ACTIVATION.md.

Mario 64 utiliza TypefaceMario64 de `fonts/` únicamente en títulos. El cuerpo y
las descripciones mantienen la tipografía predeterminada; Roboto sirve de respaldo
para los acentos ausentes en la fuente de títulos. Roles Material y helpers
comparten esa definición. CI carga la fuente real para probar ancho estrecho y
texto ampliado. Pendiente la revisión visual en dispositivo.

## Puerta de salida consolidada 1.8.3 (2026-10-14)

La preparación anterior queda consolidada en [RELEASE_1.8.3.md](RELEASE_1.8.3.md).
Notas en tres idiomas y código generado/formateado del runner están alineados.
Antes de merge/publicación quedan CI de las tres ABI, revisión física del APK
final, fecha definitiva y autorizaciones respectivas. No marcar publicación
completa únicamente porque la versión y las notas estén preparadas.


## Mario 64: recursos locales y menú original

Se integra la importación opcional de 15 texturas desde una ROM vanilla US del
usuario, sin modificar el juego ni incluir imágenes extraídas en el APK. Marcos,
selección, fondo de Biblioteca/Ajustes y contadores siguen el tema Mario; Retro y
overlay conservan su diseño. Plan, contrato, persistencia, cancelación y matriz
de pruebas en [MARIO_ROM_THEME.md](MARIO_ROM_THEME.md). Validado en [Testing #192](https://github.com/retired64/sm64cdpy.releases/actions/runs/38613827573): análisis, 83 tests Flutter,
APK arm64 y tests Kotlin correctos para `f23034a`. Sigue pendiente la matriz
física con ROM real; estos tests usan datos sintéticos y no una ROM del usuario.


## Reconstrucción Mario 64 v2 — nueva validación pendiente

Se sustituye la interpretación de 15 texturas débiles por 151 imágenes y tres
fuentes privadas derivadas de ROM: materiales opacos, cielos Clouds/BBH, cursor,
HUD, tipografías y marcos cuadrados. Se conectan todas las pantallas y widgets
principales. La selección de Mario coordina importación antes de guardar tema;
v1 conserva sus recursos mientras se pide reimportación. Contrato actual en
[MARIO_ROM_THEME.md](MARIO_ROM_THEME.md). La evidencia #192 valida v1, no este cambio v2.

## Revisión de tipografía desde capturas — 14 octubre 2026

Testing #198 completó análisis, 85 pruebas Flutter, APK arm64 y pruebas nativas.
Las capturas locales mostraron encabezados del drawer divididos por letras: el
separador ocupaba la mitad de la fila y cada sprite era un punto de salto. Mario
ahora usa la fuente de menú para encabezados de sección, 13.5 puntos y todo el
ancho disponible; los títulos destacados conservan los recursos HUD. El texto
de diálogo compartido tiene mínimo 14 puntos, peso normal y tracking cero.
Ajustes distingue opciones de 16 puntos y descripciones de 14; las rutas usan
Roboto de 14 para lectura precisa. Retro Manga conserva su escala. No cambia
la importación, el formato v2, preferencias, workers ni el engine del overlay.
Las capturas no se incluyen en el commit. Validación visual física pendiente
para el nuevo ajuste, incluidos claro/oscuro y escala de texto aumentada.

## SM64 Intro

Nuevo diseño `sm64_intro` con ambiente dorado en claro y azul nocturno en oscuro,
paneles de menú y ranuras Mario activas/inactivas. Comparte el conjunto ROM v2
con Mario 64, sin reimportación si ya está preparado. Plan, inventario de
integración y validación: `docs/SM64_INTRO_THEME.md`. Testing pendiente.

Validación: [Testing #206](https://github.com/retired64/sm64cdpy.releases/actions/runs/38636988190) completado correctamente: generación l10n, formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas. Los commits posteriores solo sincronizan formato probado y documentación. Pendiente prueba visual física de SM64 Intro.

## Ficha de mod y lectura

Portada sin banner, navegación sin solapamientos, paneles y estadísticas
adaptables. Mario eleva texto mínimo a 16 y descripción a 18 puntos.
Plan técnico: `docs/MOD_DETAIL_DESIGN.md`. Testing pendiente.
