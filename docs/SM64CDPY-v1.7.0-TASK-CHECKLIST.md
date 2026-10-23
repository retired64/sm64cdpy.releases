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

## Manga Deluxe — 2026-10-22

- [x] ID, catálogo, selector y restauración; paleta clara/oscura propia.
- [x] Familia Manga separada de decoraciones japonesas; menú/switches/audio/acento heredados.
- [x] Assets WebP optimizados de la web; ningún HTML ni vídeo dentro del APK.
- [x] Fondo estático por defecto, movimiento opcional con pausa/lifecycle/accesibilidad.
- [x] Paneles de papel, bienvenida, historia editorial DNC y demo externa bajo demanda.
- [x] FAQ en Cómo jugar, comunidad y releases Android; instalación Android existente conservada.
- [x] Reset solo visual/audio por escritores canónicos, sin borrar datos del juego.
- [x] ARB en cinco variantes, documentación y notas públicas actualizadas.
- [x] Pruebas de persistencia, capacidades, assets, fondo, editoriales y tres idiomas.
- [x] Revisado Actions 39868942338: análisis correcto, 423 pruebas verdes;
      corregidos dos fallos de japonés en Deluxe y la comprobación global del scheduler.
- [x] Actions 39875000418 pasó las pruebas y detectó un import de collection
      ausente en Home al compilar release. Import corregido; prueba real de Home añadida.
- [ ] Repetir CI y confirmar APK release completo.
- [ ] Teléfono: Home/Audio/Biblioteca/Partidas/Jugador, claro/oscuro, contraste y texto grande.
- [ ] Teléfono: movimiento, ahorro batería, minimizar, retorno del vídeo y música sin solape.

## How to use this checklist

### Switches Retro Manga — 2026-10-22

- [x] Control compartido de riel/selector cuadrados, claro y oscuro según referencias.
- [x] Audio, Biblioteca/mods/DynOS/Touch, Partidas y Ajustes migrados.
- [x] Objetivo táctil 56×48, semántica, teclado, deshabilitado y movimiento reducido.
- [x] Otros temas y lógica de persistencia/activación sin cambios.
- [x] Pruebas de forma, interacción, contraste e aislamiento con texto ampliado.
- [ ] CI: formato/análisis/tests y revisión en teléfono de ambos estados/modos.

### Marca de Inicio — 2026-10-22

- [x] Home: SM64CDPY multicolor con la fuente/contornos de Menú; lupa retirada.
- [x] Helper compartido con ajuste de ancho, sin assets o estado nuevos.
- [ ] CI y revisión en teléfono de Home claro/oscuro y ancho pequeño.

### Audio en menú deslizable — 2026-10-22

- [x] Sexta viñeta Audio con bocina de papel optimizada WebP 256 px (~19 KiB).
- [x] Controles retirados de Ajustes y reutilizados en modal con scroll/cierre.
- [x] Inicio sigue centrado, rutas y preferencias previas conservadas.
- [x] Pruebas de asset, vecinos, tres idiomas, pantalla pequeña y cierre en Jugador.
- [ ] CI: l10n/formato/análisis/tests; revisar icono y modal en teléfono.

### Música ambiental y destacados Manga — 2026-10-22

- [x] Pista Opus local, MediaPlayer asíncrono único y bucle, sin servicio de fondo.
- [x] Música al 18% inicial, switch/volumen persistentes separados de efectos.
- [x] Solo Retro Manga, propietario raíz estable, lifecycle y foco nativo 24+.
- [x] Viñeta con marco/sombra/placa semántica, favoritos 48 dp y decode máximo 960 px.
- [x] Pruebas de contrato, coordinador, persistencia y aislamiento del marco.
- [ ] CI: generar l10n, formatear, analizar, tests y Kotlin (sin SDK local).
- [ ] Teléfono: bucle sin reinicio al navegar, minimizar/llamada/rotación/juego.
- [ ] Revisar Home claro/oscuro con texto grande, imágenes remotas y gama baja.

### Volumen interno — 2026-10-22

- [x] Slider 0–100% de efectos, ganancia inicial 65%, persistente e independiente del mute.
- [x] Guardado al soltar y muestra única, reversión ante fallo y sin IPC por frame.
- [x] Ganancia Flutter → Kotlin por reproducción, sin alterar volumen del sistema.
- [x] Documentado canal independiente de música ambiental para futuro, sin pistas añadidas.
- [x] Pruebas de restauración, cero, mute, valores inválidos, fallo y payloads.
- [ ] CI: gen-l10n, dart format, analyze, tests y compilación Kotlin.
- [ ] Teléfono: 0/25/65/100%, reinicio, desactivar/activar, volumen multimedia intacto.

### Audio inaudible — 2026-10-22

- [x] APK Testing 39731678882 inspeccionado: ambos assets presentes sin compresión.
- [x] Canal de juego/multimedia y teclas de volumen alineados; sin forzar nivel.
- [x] Registros nativos de carga/decodificación/reproducción, errores Dart visibles.
- [x] Prueba de assets y payloads nativos para ambos efectos.
- [ ] Repetir CI y escuchar en teléfono con volumen multimedia y preferencia activos.

### Sonidos del menú Retro Manga — 2026-10-21

- [x] Efectos originales integrados como assets locales, SoundPool de una voz.
- [x] Pulsaciones, pasos del carrusel y cierres automáticos diferenciados.
- [x] Preferencia persistente solo Manga, traducida en cinco ARB.
- [x] Parada al minimizar/desmontar y liberación nativa al destruir el engine.
- [x] Pruebas de persistencia, aislamiento por tema y fallo del canal.
- [ ] Generar l10n/formatear/analizar/tests y compilar Kotlin en CI.
- [ ] Revisar latencia, volumen/silencio y arrastre rápido en teléfono de gama baja.

### Regresión de pruebas — Actions 39730665442

- [x] Prueba tipográfica sobre botones reales y animación entre todos los pares.
- [x] Prueba de idioma comprueba grupos por clave, incluyendo selector de acento.
- [ ] Confirmar análisis, pruebas y compilación con una nueva ejecución de CI.

### Retirada de temas — 2026-10-21

- [x] Solo Minimal, Retro Manga y Mario Kart 64 en el selector.
- [x] Preferencias antiguas de Mario 64, Intro y Minish Cap pasan a Retro Manga.
- [x] Guardado normalizado y pruebas de restauración sin perder el modo oscuro.
- [x] Revisado Actions 39724113377: corregida herencia tipográfica al cambiar
      a MK64 y dos expectativas antiguas de pruebas tras retirar temas.
- [ ] Ejecutar Flutter analyze/tests en CI y comprobar una actualización real.

### Menu-slide: navegación bajo demanda — 2026-10-21

- [x] Rama menu-slide desde drawer-ui; carrusel inicialmente oculto.
- [x] Botón Menú fijo abajo a la derecha, accesible y con acento del usuario.
- [x] Apertura/cierre por opacidad y desplazamiento breve; reducción de movimiento.
- [x] Cierre tras elegir destino, con Atrás y al pausar; modales conservan prioridad.
- [x] Teclado, texto ampliado y margen de listas coordinados por el scope.
- [x] Carga al primer uso y retención del carrusel sin actividad oculta.
- [x] Tres claves en cinco ARB y pruebas de integración del dock.
- [x] Testing 39687239343: generación/análisis correctos; fuentes sincronizadas
      desde el artefacto del runner. 436 pruebas verdes y una fallida por fixture
      de primer inicio sin Router; corregido para usar GoRouter + ShellRoute.
- [x] Tira anclada al borde inferior y cierre elevado sin solapar opciones.
- [x] Dos badges Mario Run PNG convertidos a WebP 192 px, con transición
      de imagen, elevación y compresión breve compartiendo el mismo controlador.
- [x] Palabras únicas sin cortes de letras; nombres compuestos pueden usar dos líneas.
- [x] Rótulo Menú con TypefaceMario64, letras multicolor, contorno negro
      y filete blanco adicional en oscuro; sin imágenes o tickers nuevos.
- [x] Menú abierto sin rótulo y X al 50% visual; área táctil accesible intacta.
- [ ] Repetir CI y confirmar las pruebas completas tras este ajuste.
- [ ] Comprobar en teléfono modo claro/oscuro, Atrás con borrador de Jugador,
      modales, teclado, rotación, pausa/reapertura y texto grande.

### Drawer-ui: navegación inferior Manga — 2026-10-20

- [x] Cinco grupos con acceso a todos los destinos del drawer.
- [x] Swipe para explorar; pulsación para navegar. Jugar permanece en Inicio.
- [x] Área inferior, SafeArea, teclado y variante horizontal.
- [x] Protección de borradores y ciclo de vida de controllers/modales.
- [x] Cuatro claves en cinco ARB y pruebas de regresión de navegación.
- [x] Generar localizaciones, ejecutar formato, análisis y tests en Flutter/CI:
      Testing 39494649064, 428 pruebas correctas para bd74160.
- [x] Compactar a una fila, destacar la sección activa y conservar el área táctil.
- [x] Cinco assets papercraft WebP, decodificación acotada, etiquetas accesibles
      y tests de empaquetado; sin cajas ni borde superior en la tira.
- [x] Selector compacto con escala continua al deslizar y halo del acento
      de accesibilidad; tests de foco, acento claro/oscuro y ruta sin cambiar.
- [x] Reducir la barra a unos 48 dp (sin SafeArea), con tooltip y objetivos
      táctiles de 48 dp; permitir expansión con texto accesible.
- [x] Fondo transparente sin capa oscura; cápsulas sutiles para etiquetas,
      amarillo/contorno negro en ambos modos y contraste interno en tests.
- [x] Icono centrado a escala 2 (52 dp) elevado sin cubrir la etiqueta;
      pruebas de tamaño y separación visual, conservando la barra compacta.
- [x] Fuente Mario limitada a etiquetas del carrusel, doble capa de contorno
      con semántica única y nombre corto Taller en español.
- [ ] Regenerar localizaciones (mangaNavTools en cinco ARB) y validar Flutter.
- [x] Carrusel sin trama de fondo; Game Tool en inglés y MAS sin tilde
      en español, limitados a las etiquetas de navegación.
- [x] Fondo de pantalla extendido detrás del carrusel transparente, contenido
      protegido por SafeArea y Mods como nombre de Explorar en español.
- [ ] Regenerar mangaNavExplore en CI y comprobar transparencia en teléfono.
- [x] Corregir franja persistente: quitar SafeArea global y pasar la separación
      a footers/padding desplazables; revisar listas hermanas y acción final.
- [x] Cápsulas azules en oscuro y rojas en claro, con 65 % de transparencia
      en todos los tonos del gradiente; mantener texto y barra transparente.
- [x] Mis Mods sustituye Biblioteca solo en el carrusel español, con clave
      mangaNavLibrary en cinco ARB; regeneración y prueba Flutter pendientes.
- [x] Conjunto cartoon-v2 a partir de mods.png: cinco WebP 256 px, con alfa
      real y bordes de pegatina; originales/prompts locales fuera del APK.
- [ ] Revisar nuevos iconos claros/oscuros a tamaño real en teléfono.
- [x] Ajuste 2026-10-21: fondo del tema al 85 % de opacidad y etiquetas
      completas sin elipsis; dos líneas al ampliar texto. Validación CI pendiente.
- [x] Inicio simplificado a champiñón rojo de silueta limpia y bordes de
      papel; WebP 256 px con alfa, sin cambiar navegación ni animación.
- [ ] Validar en CI el ajuste posterior a las capturas (la build anterior no lo cubre).
- [ ] Revisar Inicio/Catálogo Manga claro/oscuro en teléfono, texto grande,
      gestos Android, teclado y retorno desde CoopDX; comprobar los otros temas.

### Seguimiento de rama — Jugador, 2026-10-19

- [x] Snapshot nativo privado ligado a carpeta/permisos; lectura rápida sin listado SAF.
- [x] Perfil y paletas en lecturas separadas; editor visible mientras se refresca.
- [x] Proteger borrador/revisión ante respuestas tardías y bloquear escrituras sin verificar.
- [x] Documentar invalidación, hermanos, fuentes de verdad y límites del caché.
- [ ] Ejecutar nuevas pruebas Riverpod, análisis y compilación Kotlin en CI.
- [ ] Medir cierre/reapertura en gama baja, permiso revocado, cambio de carpeta,
      cambios externos del juego, rotación y paletas numerosas.

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
DynOS/Touch mantienen su directiva separada `dynos-pack:` dentro de Biblioteca. La validación física está pendiente.
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

Validado en [Testing #213](https://github.com/retired64/sm64cdpy.releases/actions/runs/38641643668): formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas completados correctamente. Los commits posteriores sincronizan formato probado y documentación. Pendiente revisión visual física de la ficha en claro/oscuro.

## Conexión unificada del juego

Rama `unified-game-folder` basada en `custom-themes`: user como raíz autorizada,
mods y dynos/packs derivados y ROM detectada sin otra selección. Contrato,
migración, resolver de documentos SAF y matriz: [UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md).
Validación Actions pendiente; revisión física requerida.

Conexión guiada: superficies y acciones propias de cada tema, desplegable de
Ajustes coherente con selectores y estados separados de configuración/ROM.
Validado en [Testing #229](https://github.com/retired64/sm64cdpy.releases/actions/runs/38671162732): formato, análisis, pruebas Flutter (incluidos los seis casos de tema/brillo), APK arm64 y pruebas nativas correctos para `9b0b133`. Revisión visual física pendiente. Detalle en
[UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md).

Biblioteca integra packs DynOS/Touch Controls de user/dynos/packs mediante
`dynos-pack:`; Lua conserva `enable-mod:`. Identidades por tipo/nombre, backup
y guardado verificado compartidos. VIP/OMMR Pack retiran favoritos y gesto largo.
Plan y límites: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md).
Validado en [Testing #232](https://github.com/retired64/sm64cdpy.releases/actions/runs/38679650559) para `8ff4975`: traducciones, formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas correctos. Prueba física pendiente.

## Resolución de rutas Android — esquema 2

Selección principal de com.maniscat2.sm64coopdx, cuatro rutas de lectura y
destinos de escritura en user. Lua prioriza user; DynOS prioriza raíz. Migración
limitada desde user con aviso para ampliar permiso. Contrato vigente al inicio
de [UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md). Validación del esquema 2: [Testing #237](https://github.com/retired64/sm64cdpy.releases/actions/runs/38682850283), commit `7c908c7`, completado correctamente: traducciones, formato, análisis, pruebas Flutter, compilación APK arm64 y pruebas nativas. El commit posterior solo sincroniza formato del mismo runner. Cuatro pruebas locales de scripts y `git diff --check` correctos. La matriz física sigue pendiente. El merge y la publicación se completaron posteriormente para 1.8.3.

## Apartados separados en Biblioteca

Mods del juego muestra solo unidades Lua; DynOS / Touch Controls muestra packs.
Cada apartado calcula su contador, búsqueda, filtros y paginación sobre su tipo.
La sesión de búsqueda/filtro se conserva al alternarlos usando el mismo panel
activo: no se duplican listeners, escaneos ni escritores. El bloqueo de guardado
permanece al cambiar de apartado. La restauración sigue siendo global para el
archivo compartido y se confirma como antes. Instalados, Actualizaciones e
Historial conservan su finalidad. Se admiten enlaces ?view=dynos y
?view=touch-controls; los enlaces game-mods/detected mantienen compatibilidad.
No cambia Kotlin, las rutas, el backup ni las directivas del juego. Validación
Actions validado en [Testing #240](https://github.com/retired64/sm64cdpy.releases/actions/runs/38684870621), commit `a18779d`: generación l10n, formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas correctos. Generados y formato del runner sincronizados posteriormente. Prueba física de los tres temas pendiente.


## Rendimiento de Biblioteca — 1.8.4+23 (2026-10-15)

- [x] Crear `library-performance-1.8.4` desde `main` después del lanzamiento oficial 1.8.3.
- [x] Diferir recibos y catálogos de comparación hasta abrir las secciones que los usan.
- [x] Reutilizar el snapshot de mods al navegar; revalidar tras 30 s al volver, instalación, carpeta, reanudación o refresco manual.
- [x] Mostrar el switch inmediatamente, guardar en una cola silenciosa ordenada
  y revertir con aviso si la escritura falla.
- [x] Quitar el escaneo completo posterior a cada cambio y resolver solo el objetivo Lua/DynOS.
- [x] Conservar backup, relectura exacta del config, conflictos, límite de tamaño Lua y protección WorkManager.
- [ ] Ejecutar flutter analyze, tests existentes, build APK y tests nativos en GitHub Actions.
- [ ] Medir cold load, navegación warm, activación y reanudación en dispositivo Android.

La 1.8.3 se fusionó y publicó oficialmente después de la instantánea de estado
registrada en la sección anterior. La versión vigente en esta rama es 1.8.4+23.
Detalle: [LIBRARY_PERFORMANCE.md](LIBRARY_PERFORMANCE.md) y
[RELEASE_1.8.4.md](RELEASE_1.8.4.md).

## Preparación de versión 1.8.5+24 — Jugador

- [x] Incrementar `pubspec.yaml` a `1.8.5+24`.
- [x] Integrar la pantalla Jugador en `main` y conservar el acceso desde drawer.
- [x] Editar nombre, personaje y ocho grupos de color como borrador único.
- [x] Cargar y guardar presets de paleta compatibles con el juego.
- [x] Renderizar la vista 3D desde recursos locales conectados por el usuario.
- [x] Mantener una vista compacta al desplazarse y evitar recargas por scroll.
- [x] Aplicar el perfil con bloqueo, respaldo, relectura y verificación nativa.
- [x] Crear el manifiesto canónico EN/ES/PT-BR con actualización opcional.
- [x] Documentar build base 24, versionCodes `241/242/243` y nombres de APK.
- [x] Alinear README, índice técnico, estado y CI/CD con la candidata 1.8.5.
- [ ] Ejecutar el workflow de testing sobre el commit final de `main`.
- [ ] Completar matriz física de GPU/WebView, estados SAF y dispositivos lentos.
- [ ] Fijar `publishedAt` real y autorizar el workflow de publicación.

Fuente canónica: `release-manifests/v1.8.5.json`. Puerta completa:
[RELEASE_1.8.5.md](RELEASE_1.8.5.md).

## Rendimiento visual y Minimalista — 1.8.6+25

- [x] Crear `performance-minimal-1.8.6` desde `main` después de 1.8.5.
- [x] Añadir Minimalista como diseño opcional de bajo costo.
- [x] Conservar Retro Manga como predeterminado y los cuatro diseños seleccionables.
- [x] Mantener selecciones válidas ya persistidas sin migración forzada.
- [x] Retirar SVG, `flutter_svg` y controladores de animación de destinos del drawer.
- [x] Usar filas sin iconos en el drawer Minimalista.
- [x] Restaurar el logo raster y mover enlaces sociales a Enlaces y recursos.
- [x] Quitar transición global de rutas, fade interno y Hero del detalle.
- [x] Incrementar a `1.8.6+25` y crear manifiesto localizado.
- [x] Validar análisis, 121 tests Flutter y contrato de manifiestos.
- [ ] Perfilar drawer y detalle en hardware de gama baja.
- [ ] Validar visualmente los cuatro diseños, claro/oscuro y texto grande.

Detalle y límites: [PERFORMANCE_MINIMAL_1.8.6.md](PERFORMANCE_MINIMAL_1.8.6.md).
Puerta de publicación: [RELEASE_1.8.6.md](RELEASE_1.8.6.md).

## Retro Manga: selector de acento

- [x] Rama independiente desde main; IDs persistentes y cian compatible.
- [x] Selector de Ajustes, nombres en cinco ARB y roles claro/oscuro.
- [x] Otros diseños y overlay conservan sus colores.
- [x] Pruebas de contraste y persistencia preparadas.
- [ ] Ejecutar gen-l10n, dart format, análisis y pruebas Flutter en CI.
- [ ] Revisar físicamente navegación, reapertura y texto ampliado.

## Preparación de release 1.8.7

- [x] Fusionar acentos de Retro Manga a main; Minish Cap y MK64 ya integrados.
- [x] Subir pubspec a 1.8.7+26 y preparar manifiesto y notas EN/ES/PT-BR.
- [x] Mantener forceUpdate desactivado y nombres canónicos de APK.
- [ ] Validar Testing sobre la candidata final.
- [ ] Confirmar fecha publishedAt al publicar.
- [ ] Ejecutar manualmente Build & Release con autorización del usuario.

## Decoración exclusiva de Retro Manga

- [x] Regla común para leyendas japonesas y espacios asociados.
- [x] Revisar drawer, ajustes, catálogo y secciones hermanas.
- [x] Preparar pruebas para los seis temas en claro y oscuro.
- [ ] Ejecutar Testing y revisar visualmente el APK.

## Retro Manga: superficies y controles coherentes

- [x] Completar borde y sombra dura en superficies neutras sin duplicar contratos semánticos.
- [x] Unificar `ThemeData` para campos, diálogos, menús, botones, switches, checkboxes, sliders, progreso, pestañas, `ExpansionTile`, tooltips y estados de error/deshabilitado.
- [x] Retirar overrides locales que anulaban el borde en ROM, guía, Save Files, detalle, Player y post-instalación.
- [x] Aplicar `displayLabel` en `SectionKicker` y truncar etiquetas largas en pantallas estrechas.
- [x] Mantener `popupMenuTheme` y los controles cómic aislados de los otros cinco diseños.
- [x] Pruebas locales de tema, ROM a 320/360 px con texto ampliado, guía, ajustes, Save Files y detalle.
- [ ] Revisión física en claro/oscuro, texto ampliado, ROM, Save Files, diálogos y botones deshabilitados.

## GameTool Save File

- [x] Kotlin EEPROM codec, bounded SAF store, identity/revision checks and backups.
- [x] Drawer submenu, themed screen, independent copies and editable progress.
- [x] Five ARB locales and native regression cases.
- [ ] Testing generation, analysis, Flutter/native tests and arm64 APK.
- [ ] Physical write/restore and all-theme validation with game closed.

### Save File menu clarity

- [x] Group Library, Player and Save File under GameTool; retain existing routes.
- [x] Tap a slot card to edit it; identify its copy and live draft star count.
- [x] Move secondary copies to explained advanced controls and label the 120-star preset as an action.
- [ ] Check card taps, draft cancellation and explicit Apply in light/dark on device.

- [x] Group Exclusive categories in a themed drawer submenu and place Popular above GameTool; preserve existing routes and localized category labels.

- [x] Complete drawer groups: Explore (Catalog, Popular, Favourites), GameTool, Exclusive and Resources; Home/Settings stay direct.
- [x] Share themed group headers, independent expansion and active-route highlighting without adding persistent preferences.
- [ ] Verify drawer expansion, screen-reader announcements and text scaling on device in each theme.

- [x] Unify root drawer typography and row sizing; prevent decorative navigation-title wrapping; distinguish Exclusive and Render96 icons.
- [ ] Review narrow-screen and enlarged-text drawer presentation on device across themes.

- [x] Localize the game-tools group and save-file destination in both Spanish and Portuguese variants; shorten the Links navigation label across languages.

### Cierre de preparación 1.8.7

- [x] Fusionar las traducciones del drawer en main conservando la actualización del catálogo.
- [x] Consolidar las notas de temas, acentos, Partidas y navegación en el manifiesto canónico.
- [x] Regenerar previews EN/ES/PT-BR y validar versión 1.8.7+26 y contrato Python.
- [ ] Ejecutar manualmente Build & Release cuando el propietario decida publicar; revisar fecha real y las tres ABI.


- [x] Remove unsupported coin editing and preserve raw coin records in progress-only writes; add both-endian preservation regression coverage.

- [x] Replace confusing internal-copy labels with Game progress → Normal / Alternative; explain mod usage and preserve bank identity and explicit copy/erase scope.

- [x] Keep the SM64CDPY drawer-header logo consistent when switching between Retro Manga, Minish Cap and Mario Kart 64.


## Optional fast installation

- [x] Integrate example writer behind shared ZIP/7z/loose-file sinks.
- [x] Validate all four destination layouts and reject Android/, nonprimary IDs, traversal and symlinks.
- [x] Reuse manual copy logic, preserve cancellation, receipts and terminal events.
- [x] Optional localized permission action with resume recheck; Android 10 stays SAF.
- [x] Invalidate native discovery after installation; notify Flutter on manual success.
- [ ] Full Testing compilation and suites.
- [ ] Device performance, permission revocation, reinstall, cancellation and app/overlay matrix in FAST_INSTALLATION.md.

## Preparación de release 1.8.8

- [x] Fusionar `minish-cap-visual-overhaul` en `main` conservando instalación rápida y optimizaciones visuales.
- [x] Subir `pubspec.yaml` a 1.8.8+27 y reservar versionCodes ABI 271/272/273.
- [x] Preparar manifiesto canónico y notas EN/ES/PT-BR con fecha provisional.
- [x] Mantener el permiso de administrar todos los archivos como opción explícita y conservar SAF como fallback.
- [x] Ejecutar análisis, pruebas Flutter/Kotlin y compilación APK debug local.
- [ ] Validar físicamente permiso concedido/revocado, ZIP, 7z, archivo suelto, cancelación y refresco de Biblioteca.
- [ ] Ejecutar Testing en `main`, confirmar `publishedAt` y publicar solo con autorización explícita.

## Preparación de release 1.9.0 — ROM converter y Retro Manga

- [x] Integrar el preparador local de ROM desde Cómo jugar y GameTool.
- [x] Detectar z64/v64/n64 por cabecera, validar tamaño/MD5 USA y exportar `.z64` por SAF sin modificar el original.
- [x] Añadir progreso por fase, cancelación, reintento, errores accionables y estados `prepared`/`saved` diferenciados.
- [x] Completar Retro Manga con superficies de cartón, controles Material coherentes y encabezados inclinados truncables.
- [x] Aislar `popupMenuTheme` y los controles cómic de los otros cinco diseños.
- [x] Actualizar `pubspec.yaml` a `1.9.0+28` y reservar versionCodes ABI `281/282/283`.
- [x] Preparar manifiesto canónico y previews EN/ES/PT-BR con fecha provisional.
- [x] Validar manifiesto contra pubspec, pruebas Python, formato, análisis y 280 pruebas Flutter.
- [x] Mantener la desinstalación segura fuera de esta candidata; sigue como roadmap posterior.
- [ ] Fusionar `how-to-play-guide` en `main` sin crear todavía el tag.
- [ ] Ejecutar Testing en `main` y revisar el APK arm64 firmado.
- [ ] Matriz física: proveedores SAF locales/remotos/lentos, rotación, poco espacio, cancelación, ROM real y exportación.
- [ ] Revisión visual física de Retro Manga en claro/oscuro, 320/360 px, texto ampliado, ROM, Save Files, diálogos y estados deshabilitados.
- [ ] Confirmar `publishedAt`, tag `v1.9.0` y publicar solo con autorización explícita.

## How to Play — how-to-play-guide

- [x] Seis pasos localizados y ayudas de conversión/rutas.
- [x] Drawer y lanzamiento compartido Home/guía/postinstalación.
- [x] Conexión existente y estado comprobado al reanudar, sin cache nuevo.
- [x] Generación l10n, formato, análisis y 250 pruebas Flutter en Testing 39337289411.
- [ ] Prueba física desde juego ausente hasta primer mod activo.

- [x] Revisar capturas y sustituir bloque largo por tarjetas tituladas y capítulos deslizables.
- [x] Mapa modal, navegación fija y estructura visual por tema.
- [x] Validar guía v2 con gestos, texto ampliado y landscape: 253 pruebas Flutter en Testing 39340475646.
- [ ] Revisión física de guía v2 y APK final.

- [x] Sustituir iconos genéricos de personajes por cinco PNG locales pequeños.
- [ ] Validar visualmente selector de Jugador en dispositivo y texto ampliado.
- [ ] Optimización del spinner de Jugador: pospuesta por el usuario.

- [x] Análisis, formato y pruebas Flutter para retratos: Testing 39342619343.

- [x] Identificar fallo de build Player como descarga NDK inválida.
- [x] Preparación compartida del NDK y ocho pruebas Python aprobadas.
- [x] Reproducir colisión bool/double en PageStorage y separar claves de expansión/texto/lista.
- [x] Verificar regresión de expansión/restauración en seis temas y tres idiomas: Testing 39344333533.
- [x] Testing nuevo con APK arm64 y pruebas nativas completos: 39344333533.

- [ ] Comprobación física de conversión/rutas y retratos de Player con cdpy-f10f833-TESTING.

## Home Deluxe compacto — 2026-10-22

- [x] Retirar showcase especial DNC de Home, conservando catálogo y demo en detalle.
- [x] Bienvenida compacta, guía y Omitir persistente con salida ante error.
- [x] Gorros a 80 dp, trama a 110 dp y papel neutro translúcido solo en Deluxe.
- [x] Traducciones EN/ES/ES-419/PT/PT-BR y pruebas de restauración/layout.
- [ ] Ejecutar gen-l10n, dart format, analyze y tests en CI (sin SDK local).
- [ ] Revisar Home Deluxe claro/oscuro en Android, texto grande y movimiento reducido.

## Movimiento Deluxe perceptible — 2026-10-22

- [x] Período 12 s y planos fijos con traslación sin relayout por fotograma.
- [x] Prueba de posición al activar/desactivar/reactivar sin remontar el fondo.
- [ ] Ejecutar format/analyze/tests en CI y verificar switch en Android.

## Cabeceras del menú deslizable — 2026-10-22

Audio, Mods, Herramientas y Más comparten `MangaSubmenuHeader`: WebP de su
opción a 40 dp, decodificación acotada a 128 px, título Mario multicolor y cierre
localizado. Las secciones internas de Más usan el mismo rótulo multicolor;
los grupos simples evitan repetir su título. Semántica de encabezado única,
texto ajustable al ancho y cierre táctil de 48 dp. Sin nuevas imágenes,
animaciones, dependencias ni cambios de navegación/estado/audio.

Prueba de cabecera a 320 px/texto 1,6× en EN/ES/PT y claro/oscuro con cierre.
Pendiente format/analyze/tests en CI y revisión física por falta de SDK local.

## Fuente de opciones Manga Deluxe — 2026-10-22

Las opciones de los submenús Mods, Herramientas y Más usan `MarioAndLuigi`
(400, 20 sp, altura 1,25) solo en Manga Deluxe. Registrada en pubspec desde
`fonts/manga_deluxe/MarioAndLuigi-0v99.ttf` (~20 KB), con nota de procedencia
original y fallback Roboto. El color continúa heredando ListTile para respetar
la selección; las filas crecen con el texto, sin altura fija. Cabeceras Mario
multicolor y tipografía de los demás temas permanecen independientes. No se
aplica a descripciones, volúmenes ni controles de Audio.

Prueba añadida de alcance Deluxe/Retro Manga en los tres grupos, con texto
1,6×. Pendiente format/analyze/tests en CI y revisión física por falta de SDK.

## Lectura del detalle Manga Deluxe — 2026-10-22

`SuperMarioWorldTextBox` se registra desde el TTF proporcionado (~12 KB), con
nota de procedencia en fonts/manga_deluxe. Solo descripción (contraída/expandida),
autor, etiquetas y rótulos/valores de primera publicación y última actualización
del detalle general usan esta fuente en Manga Deluxe. Helper local conserva
colores, usa peso real 400, mínimo 16 sp, interlínea 1,5 y fallback Roboto.
No se cambia el tema global, las cabeceras, acciones ni otros temas/pantallas.
Las fechas mantienen formato localizado y disposición adaptable existentes.

Prueba de layout existente ampliada para verificar alcance de fuente por tema.
Pendiente ejecutar format/analyze/tests en CI y revisar texto grande en Android.

## Ajuste tipográfico Deluxe — 2026-10-22

WonderMermaid sustituye a MarioAndLuigi en el registro y opciones de submenús
Deluxe, manteniendo 20 sp y fallback Roboto. Archivo OTF original (~26 KB) y
licencia adjunta en fonts/manga_deluxe; el autor indica uso personal gratuito,
con licencia comercial separada. No se altera la tipografía de otros temas.

El helper de lectura del detalle acepta una escala exclusiva Deluxe: autor y
descripción pasan de 16 a 12 sp (-25 %), etiquetas de 16 a 8 sp (-50 %).
Fechas y cabeceras conservan tamaño. El escalado de accesibilidad del sistema
permanece activo. Pruebas de fuente y tamaño actualizadas; ejecución de Flutter
pendiente en CI por falta de SDK local.

## Fuente de opciones Supreme Spike — 2026-10-22

SupremeSpike sustituye a WonderMermaid en las opciones de submenús Manga
Deluxe. Se registra el OTF proporcionado (~64 KB), manteniendo 20 sp, peso 400,
fallback Roboto y colores heredados de selección. Sin cambios en títulos
multicolor, descripción/autor/etiquetas/fechas ni otros temas. El directorio
proporcionado no incluye archivo de licencia; no se atribuye una licencia
no comprobada. Prueba de alcance actualizada; Flutter pendiente en CI.

## Presentación Play — 2026-10-23

`coop_play_visuals.dart` contiene únicamente título, icono, estilo de lectura y
acción visual. Ambos temas Manga usan rótulos Mario multicolor, bordes/sombras
existentes y WebPs Play/Explore compartidos (decode 128 px). Deluxe usa Supreme
Spike en acciones y Super Mario World en lectura; otros temas conservan sus
controles GameSetupAction. Sin nuevas imágenes, dependencias ni animaciones.

CoopSessionScreen mantiene íntegros controlador, lifecycle, consentimiento,
validación, callbacks y selección de fases. La presentación evita repetir el
título; privacidad puede expandirse y revisar consentimiento sigue accesible.
Solo muestra falta de juego cuando gameInstalled == false; el estado desconocido
no se presenta como éxito. La tarjeta de batería aparece únicamente si supported
&& !ignored, y desaparece al actualizar el permiso con el flujo existente.

Provider, servicios, dominio, WebView, Kotlin, Manifest y assets/coop no cambian.
Las vistas leen el estado existente y no escriben preferencias nuevas ni tienen
caches. El reset, navegación, notificación y overlay no cambian. No hay nuevos
Futures sin esperar ni suscripciones.

Pruebas añadidas: 320 px/texto 1,5×, claro/oscuro, ES/EN/PT, ambos Manga,
requisitos resueltos/pendientes, entrada del código, acciones por fase y callback
habilitado/deshabilitado. Pendiente dart format, flutter analyze y flutter test
por falta del SDK local, además de revisión física del teclado y ciclo de sesión.

## Corrección de pruebas — Actions 40007818120

El análisis pasó; 457 pruebas pasaron y las 12 variantes de Play compacto
fallaron con `Bad state: No element` antes de alcanzar el formulario. El test
usaba `.last` sobre botones aún no construidos por ListView, seguido de
ensureVisible. Se desplaza primero con scrollUntilVisible sobre el Scrollable
principal hasta el TextField y la acción de unirse identificada por su icono.
Se mantienen comprobaciones de layout, código y ambos temas/idiomas/modos.
Sin cambios en código de app, motor ni contratos. Pendiente repetir CI; SDK
Flutter/Dart no disponible localmente. git diff --check validado.
