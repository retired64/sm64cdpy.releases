# Estado y próximos pasos

Revisado para la candidata `1.8.8+27` en `main` el 2026-10-19. La 1.8.7 es la versión anterior.

## Implementado

- Tema Minimalista de bajo costo disponible en Ajustes, sin fondos pintados,
  sombras, inclinaciones ni iconos en el drawer. Retro Manga es nuevamente el
  predeterminado; los cuatro diseños y las preferencias válidas se conservan.
  Drawer y detalle eliminan SVG y transiciones superpuestas.

- Catálogo principal y colecciones auxiliares desde JSON local/remoto.
- Búsqueda, filtros, orden, paginación, favoritos e importación/exportación.
- Localización EN/ES/PT y temas claro/oscuro.
- Selección de carpetas con SAF y lanzamiento del juego.
- Descarga/instalación WorkManager con progreso, cancelación y notificaciones.
- ZIP, 7z y archivos sueltos.
- Actualizaciones OTA por ABI.
- Overlay con búsqueda, órdenes de descarga y reflejo del progreso.
- Identidad canónica de contenido/artefacto compartida por app, overlay,
  WorkManager, persistencia temporal y eventos.
- Recibos nativos atómicos para instalaciones automáticas confirmadas, con
  manifiesto SAF acotado y recuperación independiente de los engines Flutter.
- Repositorio de Biblioteca con lectura nativa validada, historial de hasta 500
  eventos, proyección Hive reconstruible y estado Riverpod listo/parcial/error.
- Verificación SAF acotada por centinelas con estados presente, ausente,
  desconocido y permiso revocado; refresco global e individual fuera del hilo
  principal.
- Selector canónico de acciones aplicado a detalle, VIP, DynOS, Touch
  Controls, OMM, Render96 y overlay, con comparación conservadora de versiones.
- Biblioteca y Home con vistas instaladas/recientes, filtros, reconciliación
  SAF y navegación hacia el contenido de origen.
- Snapshot versionado de Biblioteca hacia el segundo engine del overlay, con
  descarte de respuestas antiguas y actualización tras instalación,
  verificación o cambio de carpeta.
- Vista única Mods del juego para unidades Lua válidas, propias o externas,
  con activación verificada y metadata limitada de autor/categoría/versión/descripcion.
  Detectados fue retirada; no se inventan recibos ni identidades de catálogo.
- Actualizaciones de Biblioteca contra artefactos canónicos del catálogo,
  clasificación durable de instalación/actualización/reinstalación, reemplazo
  lógico recuperable y mantenimiento individual sin borrar archivos del juego.
- Biblioteca alineada visualmente con Catálogo mediante pestañas y filtros
  inclinados, contadores, menús retro y estados vacíos coherentes. Los filtros
  gobiernan Actualizaciones y solo aparecen con opciones reales; las tarjetas
  evitan estados duplicados y detalles internos de detección.
- Modo oscuro con lienzo casi negro y superficies escalonadas inspiradas en
  GitHub Dark; conserva el acento cyan, usa bordes gris intermedio y reduce la
  trama de fondo para evitar una apariencia gris, deslumbrante o excesivamente
  luminosa.
- Navegación raíz unificada con barra superior compacta y fija: el botón del
  drawer permanece disponible durante scroll, carga y error. El drawer vuelve
  al inicio al abrirse, navega sin retraso artificial y ya no duplica los
  filtros y el ordenamiento propios del Catálogo.
- Contrato de catálogo v2 con identidades estables de versión/archivo,
  compatibilidad temporal con recibos posicionales de 1.8.0 y aprovechamiento
  de metadata de resolución/procedencia del scraper.
- Actualización remota transaccional: validación integral previa, control de
  esquema y conteo, barrera contra reducciones anómalas, reemplazo atómico,
  copia `last-good`, cuarentena y fallback a la base incluida en el APK.
- Resolución en tiempo de descarga para páginas estables de MediaFire,
  GameBanana y archivos de Google Drive; las carpetas Drive no resolubles se
  presentan como enlace de origen sin afirmar que fueron instaladas.
- Pantalla Jugador para editar nombre, modelo Mario/Luigi/Toad/Waluigi/Wario y
  ocho grupos RGB de `user/sm64config.txt`. Android comparte bloqueo, respaldo,
  revisión y verificación con la activación de mods; Riverpod conserva un
  borrador y aplica todo el perfil en una transacción. Los presets usan
  `[PALETTE]` en `user/palettes`. La vista previa anterior PNG/pose fija fue
  retirada: un PlatformView Android aislado reconstruye en WebGL el modelo real
  desde `libmain.so` del juego instalado y la ROM USA autorizada, permite giro e
  intercambia la paleta en vivo. No se incluyen modelos, texturas, ROM ni binario
  del juego en el APK. Arquitectura y evidencia: [PLAYER_3D_RENDERER.md](PLAYER_3D_RENDERER.md).

## Temas incluidos en custom-themes (2026-10-13)

- Menú de diseños propios y menú de modo de brillo independientes, ambos expandibles en Ajustes.
- Dos definiciones incluidas (Retro Manga y Mario 64); contraste, radios, bordes, sombras y decoración
  adaptados en las pantallas y widgets de la app.
- Persistencia confirmada y recuperación legacy; overlay mantiene diseño fijo.
- ARB y pruebas preparados; generación, análisis, tests y APK pendientes en
  Actions porque el entorno Termux de esta tarea no tiene Flutter/Dart.
- Guía/inventario completos: [cuatom_themea.md](../cuatom_themea.md).

## Experimental o pendiente de validación

- Biblioteca/historial: implementación funcional completada; falta ampliar la
  matriz física con proveedores SAF lentos, permisos revocados y texto grande.
- Sincronización de Biblioteca en overlay: implementada y cubierta por pruebas
  de codec/identidad/selector y por una matriz física de diez escenarios.
- Descubrimiento externo: fase 8 completada con pruebas automatizadas y matriz
  física aprobada en dispositivo real para contenido estructurado, Lua suelto,
  actualización manual, permisos/carpetas, exclusión de duplicados y protección
  frente a archivos parciales de una instalación activa.
- Actualización y mantenimiento de Biblioteca: fase 9 implementada y cubierta
  por pruebas automatizadas; pendiente matriz física de actualización,
  reinstalación, downgrade voluntario, reapertura y overlay.

- Overlay en Android 7–16, especialmente recreación del proceso y retorno desde permisos del sistema.
- Descargas simultáneas en dispositivo; las colisiones por títulos ya no son
  parte del identificador, pero falta validación física del paralelismo.
- Restauración visual de trabajos activos después de reiniciar la app/engine.
- Proveedores SAF distintos (Files de Google, fabricantes y almacenamiento externo).
- URLs externas no cubiertas por la resolución especializada.
- Jugador 3D: pendiente matriz física en varios GPU/WebView, incluyendo pérdida
  de permiso SAF, juego ausente, ROM inválida, rotación y regreso desde segundo plano.

## Deuda priorizada para retomar el proyecto

1. Crear pruebas unitarias para sanitización, resolución de URL, modelos y selección de assets OTA.
2. Crear una prueba de integración del flujo UI → MethodChannel → WorkManager → EventChannel con dobles de plataforma.
3. Ejecutar una matriz manual Android 7, 10, 13, 14 y 16 con descarga, cancelación, segundo plano y pérdida de permiso.
4. Verificar en dispositivo dos descargas paralelas y colisiones de nombres e IDs de notificación.
5. Revisar la restauración de `_infoMap` desde WorkManager tras process death.
6. Añadir una comprobación CI ligera para pull requests cuando el repositorio vuelva a tener una estrategia de ramas estable.

## Posterior a 1.8.0

La desinstalación física queda planificada para `1.9.0` en tres fases:
manifiesto completo de propiedad, Worker SAF conservador y sincronización de la
experiencia entre Biblioteca, catálogo y overlay. El plan está en
[SAFE-UNINSTALL-v1.9.0-ROADMAP.md](SAFE-UNINSTALL-v1.9.0-ROADMAP.md). Los
centinelas actuales verifican presencia, pero no se usarán como autorización
para borrar archivos.

## Fuera del estado vigente

`floating-check-list.md`, `revision-app.md` y `.opencode/plans/` son fotografías de análisis anteriores a/durante 1.7.0. Contienen puntos ya resueltos y otros no revalidados; no deben usarse como backlog sin contrastarlos con el código. El inventario completo está en [archive/README.md](archive/README.md).

### Ajustes visuales posteriores a la prueba aprobada

Selector de idioma alineado con los dos selectores de apariencia, manteniendo
animaciones. Mario 64 usa paneles discretos, iconos/toggles redondeados y
cabeceras limpias en Ajustes. Código y pruebas añadidos; nueva Actions y matriz
física de idioma/tamaño de texto pendientes.

## Release oficial 1.8.3+22

- Notas finales EN/ES/PT-BR incluyen Biblioteca unificada, edición de mods,
  Retro/Mario, ajustes y fuente de títulos; previews generadas para revisión.
- Testing #183–#186 terminó correctamente; #187 pasó análisis/78 tests Flutter.
- Generación/formato de #187 incorporados solo en archivos del alcance.
- Merge simulado contra main remoto `8bdc996` sin conflictos, sin fusionar.
- Testing admite todas las ABI por input manual o `[testing] [all-abis]`.
- La publicación oficial de 1.8.3 se completó. Alcance y notas localizadas:
  [registro del release](RELEASE_1.8.3.md).

## Activación de mods — release 1.8.3

Biblioteca incluye una sección de unidades Lua del juego con switches de selección
para el próximo inicio. SAF autoriza `user`; el servicio nativo conserva ajustes,
comprueba identidades/incompatibilidades/tamaño, crea respaldo y verifica la escritura.
DynOS/Touch mantienen su directiva separada `dynos-pack:` dentro de Biblioteca. La validación física está pendiente.
Plan, archivos, estados y matriz: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md).
Ambos workflows ejecutan también `:app:testReleaseUnitTest`. Esta implementación se publicó con 1.8.3.

## Rendimiento de Biblioteca — 1.8.4+23

Implementación publicada en 1.8.4. Biblioteca carga recibos y catálogo de comparación bajo
demanda; Mods del juego/DynOS reutiliza un snapshot reciente y actualiza el
switch en el primer frame. Android procesa los cambios en una cola silenciosa y
ordenada; solo un fallo revierte el último valor afectado y avisa. El guardado ya
no reconstruye todo el catálogo después de cada cambio y valida solo el objetivo
y los mods activos relacionados, manteniendo respaldo, control de conflictos,
tamaño Lua y bloqueo durante instalaciones. La medición física ampliada sigue
siendo recomendable. Detalle: [LIBRARY_PERFORMANCE.md](LIBRARY_PERFORMANCE.md) y
[preparación 1.8.4](RELEASE_1.8.4.md).

Biblioteca integra Mods del juego como pestaña nativa del sistema visual, con
búsqueda y filtros locales, contador de activados, tarjetas adaptadas a cada
diseño y confirmación de juego cerrado por visita (reiniciada al reanudar).
Restaurar continúa exigiendo confirmación; cada escritura conserva la autoridad
nativa. Ver [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md), integración visual.

Mario 64 utiliza TypefaceMario64 de `fonts/` únicamente en títulos. El cuerpo y
las descripciones mantienen la tipografía predeterminada; Roboto sirve de respaldo
para los acentos ausentes en la fuente de títulos. Roles Material y helpers
comparten esa definición. CI carga la fuente real para probar ancho estrecho y
texto ampliado. Pendiente la revisión visual en dispositivo.


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
Validado en [Testing #225](https://github.com/retired64/sm64cdpy.releases/actions/runs/38658236343): generación l10n, formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas correctos para `458189b`. La sincronización posterior solo incorpora formato del runner. Revisión física de permisos, rutas y ROM requerida.

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

## Retro Manga: acentos personales

Rama `retro-manga-accent-accessibility` desde main: Ajustes ofrece ocho acentos
persistentes exclusivos de Retro Manga, con texto ajustado para contraste y
selección independiente del modo claro/oscuro. Incluye pruebas de contraste,
aislamiento de otros temas y restauración. Pendiente validar generación l10n,
análisis y pruebas Flutter en CI, además de revisión física con texto ampliado.

## Candidata 1.8.7+26

Minish Cap, Mario Kart 64 y los ocho acentos accesibles de Retro Manga están
integrados en main. Manifiesto canónico: `release-manifests/v1.8.7.json`; notas
EN/ES/PT-BR generadas desde ese archivo. La fecha es provisional hasta publicar.
Testing de acentos aprobado en da7c12f (run 39142810984); usuario confirmó su
funcionamiento. Validación de la candidata final y publicación manual pendientes.

La rama de accesibilidad reserva las leyendas japonesas decorativas a Retro
Manga en todas las pantallas compartidas. Incluye prueba de encabezados para
cada diseño en ambos modos; validación remota pendiente.

## GameTool Save File — Testing candidate

New drawer submenu and original-game save editor: four slots with independent
copies, course stars, cannon state, coin scores, castle stars and unlocks.
Private full backups precede verified mutations. Native tests prepared; remote
validation and physical review pending. See GAME_SAVE_FILE.md.

Save File menu polish: Library and Player now share the GameTool submenu.
Tappable slot cards lead to a draft with its own star total; 120-star completion
is an explicit action. Secondary internal copies are an explained advanced option.

Drawer navigation: Home and Settings remain direct links. Explore groups Catalog, Popular and Favourites; GameTool groups Library, Player and Save File; Exclusive groups Render96, Mods, DynOS, Touch Controls and Omm Pack; Resources groups Links and Disclaimer. Each group expands independently and highlights its active route. Existing routes remain unchanged.

Drawer visual polish: consistent Home/Settings and group-header typography, a compact navigation caption for narrow screens, and separate collection/3D-model icons for Exclusive/Render96.

Drawer localization: Spanish uses Herramientas / Partidas / Enlaces; Portuguese uses Ferramentas / Dados salvos / Links. English keeps GameTool / Save File and shortens Links. Save screen headings share the same translated label; routes remain unchanged.


Save File no longer exposes coin editing. Progress edits omit coin records so Kotlin preserves their original bytes; stars, cannons, unlocks, copy/erase and backups remain available.

Save progress terminology now uses Normal / Alternative under Game progress in all five locales. The explained alternative belongs to some mod-specific modes; it is distinct from dated backups and does not select a game mode. Native bank mapping is unchanged.

The drawer header always shows the SM64CDPY application logo, including Minish Cap and Mario Kart 64; theme artwork remains available for theme-specific presentation elsewhere.

Pending Testing: optional faster installation in Settings, contained primary-storage direct writes for ZIP/7z/loose files, preserved SAF fallback, direct rollback of new entries, and discovery invalidation after installs. Android 10 deliberately remains on SAF. No on-device speed claim yet.

## Candidata 1.8.8+27

El overhaul visual de Minish Cap, los acentos adaptables de Mario Kart 64 y las
optimizaciones compartidas de renderizado están integrados en `main`. La
instalación rápida opcional añade escritura directa únicamente en destinos
compatibles del almacenamiento principal cuando el usuario concede el permiso
de administrar todos los archivos; SAF continúa como ruta estándar y fallback.

Manifiesto canónico: `release-manifests/v1.8.8.json`. Notas EN/ES/PT-BR,
validación final, APK de prueba y matriz física de permisos/extracción pendientes.

## Guía de inicio — rama how-to-play-guide

Seis pasos EN/ES/PT-BR en Recursos, instalación del port Android, ROM USA .z64,
conversión explicada, conexión unificada y primeros mods. Lanzamiento fallido
ofrece guía si falta el juego. Testing 39337289411 aprobó generación l10n,
formato, análisis sin errores nuevos y 250 pruebas Flutter. APK en compilación;
validación física pendiente.
Contrato y matriz: [HOW_TO_PLAY.md](HOW_TO_PLAY.md).

Guía v2: capítulos deslizables, mapa modal y 32 tarjetas tituladas con materiales
propios de cada tema. Navegación fija y layout compacto en landscape.
Testing 39340475646 aprobó generación, formato, análisis y 253 pruebas Flutter,
incluidos mapa/gestos en landscape. APK arm64 en compilación y revisión física
pendiente; la evidencia anterior valida la primera estructura.

Jugador: selector con PNG originales de Mario/Luigi/Toad/Waluigi/Wario,
renderizados a 32 puntos desde imágenes de 16×16 cacheadas por Flutter.
Se conserva la lógica del perfil. Optimización de carga/spinner pospuesta.

Corrección de build pendiente de Testing: la descarga del NDK falló con ZIP
inválido en 39342619343. Ambos workflows ahora preparan/verifican el NDK exacto
de Flutter con tres intentos acotados. Se investiga además el desplegable de
conversión de ROM; la captura confirma ErrorWidget gris dentro de la guía.

Pantalla gris de conversión reproducida: colisión PageStorage entre booleano
de ExpansionTile y offset de SelectableText. Claves separadas para conversión,
rutas y cada texto; regresión ampliada pendiente de Testing final.
