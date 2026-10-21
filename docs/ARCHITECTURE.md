# Arquitectura actual

Revisado para `1.8.5+24` en `main` el 2026-10-15.

## Alcance

SM64CDPY es una aplicación Flutter orientada exclusivamente a Android. Combina una interfaz Flutter, integración nativa Kotlin y trabajo persistente de Android. El directorio `linux/` es scaffold generado y no representa soporte de escritorio.

## Capas

| Área | Ruta | Responsabilidad |
|---|---|---|
| Núcleo | `lib/core/` | Constantes, rutas, tema y utilidades |
| Datos | `lib/data/` | Lectura de JSON, caché, modelos y repositorio |
| Dominio | `lib/domain/` | Entidades e interfaz del repositorio principal |
| Presentación | `lib/presentation/` | Pantallas, widgets y estado Riverpod |
| Servicios | `lib/services/` | OTA, resolución de URLs y puentes con Android |
| Overlay | `lib/overlay/` | UI flotante y puente con el engine principal |
| Android | `android/app/src/main/kotlin/mods/sm64cdpy/` | SAF, WorkManager, extracción y canales Flutter |

La arquitectura es deliberadamente híbrida: el catálogo principal utiliza entidades/repositorio; las colecciones pequeñas tienen datasources y providers directos.

## Navegación Retro Manga — drawer-ui, 2026-10-20

AppShell usa MangaNavigationScope y MangaNavigationBar solo en Retro Manga.
Inicio, Explorar, Biblioteca, Herramientas y Más conservan todas las rutas.
Explorar reúne catálogo/populares/favoritos; Herramientas agrupa Jugador,
Partidas y Preparar ROM; Más conserva Ajustes, exclusivos y Recursos.
Los otros cinco temas mantienen AppDrawer y DrawerMenuButton.

GoRouter/currentRoute es autoridad sobre selección. PageController conserva
solo qué viñeta se explora: deslizar no navega ni abre el juego. Pulsar un destino
navega tras cerrar el panel modal; la nueva ruta centra su grupo. Los paneles
admiten scroll, arrastre para cerrar y botón Cerrar. Jugar permanece en Inicio,
usa launchGameWithGuide y su confirmación cuando falta el juego; no es una pestaña.

Las dos barras canónicas y Aviso legal consultan el scope para retirar el
hamburguesa únicamente bajo la navegación inferior real. Scaffold reserva
espacio para la tira, respeta SafeArea y la oculta con el teclado. AnimatedScale
respeta reducción de movimiento; la trama usa HalftoneBackground existente.
El carrusel repite los cinco grupos para que el activo pueda quedar centrado
y tenga vecinos a ambos lados. Construye solo celdas visibles y omite índices
semánticos artificiales; los controles conservan nombre, acción y selección real.

PageStorageBucket del shell conserva offsets compatibles, aislados por ruta;
se descarta al destruir el shell. No conserva todos los State/controles ni
cachea datos del juego. Los providers siguen siendo autoridad de sus datos.
Antes de abandonar Jugador se comprueba busy/dirty y se pide
confirmación para descartar. No hay preferencias nativas ni mensajes al overlay.
Los métodos usados con unawaited capturan errores y liberan busy en finally.
PageController y callbacks pendientes se protegen con dispose/mounted.

Cuatro claves nuevas están en los cinco ARB; ejecutar flutter gen-l10n sin editar
generados. Nuevas pruebas: aislamiento de temas, espacio de contenido, swipe sin
navegación, rutas de herramientas y Más, teclado, borrador y lanzamiento.
Validación Flutter y física pendiente: este Termux carece de Flutter/Dart.

Primera build 39492939735: análisis correcto y 422 pruebas verdes; dos pruebas
de lanzamiento fallaron porque Platform.isAndroid era falso en el host Linux
y omitía el MethodChannel simulado. GameLauncherService usa ahora
!kIsWeb + defaultTargetPlatform Android, con variantes Android explícitas en
los widgets y cuatro pruebas del servicio (éxito, ausencia, otras plataformas
y errores). El bloqueo a plataformas no Android sigue vigente. Traducciones y
formato de los archivos afectados se sincronizan desde el artefacto del runner;
la nueva ejecución debe validar el conjunto antes de declarar lista la build.

Testing 39494649064, candidata bd74160: generación, formato y análisis correctos;
428 pruebas Flutter verdes. Los tests de Cómo jugar simulan explícitamente el
juego ausente y las acciones buscan las etiquetas con displayLabel del tema.
No se eliminan las comprobaciones de lanzamiento/confirmación para pasar CI.
La ejecución terminó correctamente, incluidas las pruebas nativas y el APK
`cdpy-bd74160-TESTING`. El análisis pasó sin errores ni warnings; conserva avisos
informativos de estilo. La comprobación visual en un teléfono sigue pendiente.

### Ajuste a partir de las capturas — 2026-10-20

La tira pasa a una única fila de icono y nombre, sin instrucción visible,
checks/flechas inferiores ni lanzamiento duplicado. La ayuda de deslizamiento
permanece en Semantics. Jugar vuelve al bloque original de Inicio para todos
los temas, reutilizando su protección contra doble toque y la guía de instalación.
La altura base es de aproximadamente 48 dp más SafeArea y crece con la escala
de texto. Cada celda ocupa el 32 % del ancho y conserva su área táctil completa.
El fondo combina papel y tinta del tema (85 % de tinta) con opacidad 88 %.
Se compone sobre el fondo del Scaffold; no se extiende sobre el contenido ni
requiere BackdropFilter/blur. Las etiquetas y la trama usan un primer plano
calculado con onColor sobre el color compuesto para mantener contraste en
claro y oscuro. La opacidad no afecta a iconos, textos ni halo de acento.
Los cinco iconos papercraft flotan sin cajas, divisores ni borde superior. Solo
la imagen se escala: el icono centrado llega a 1.28 (unos 33 dp) y sus vecinos
a 0.62 (unos 16 dp). AnimatedBuilder observa el PageController y calcula la
escala por distancia al centro en cada fotograma, sin reconstruir el shell ni
navegar. Un halo elíptico con sombra corta usa retro.accent del ThemeExtension
vigente; no mantiene copia local del color. Ajustes escribe la preferencia de
acento existente y main reconstruye el tema, que actualiza este consumidor.
Al reducir movimiento, el énfasis cambia al centro sin interpolación adicional.
La etiqueta subrayada y Semantics.selected siguen indicando la ruta abierta,
aunque se explore otro grupo. Las etiquetas conservan su tamaño accesible y el color de
tinta; la activa añade peso y subrayado con el acento del usuario.
La barra ocupa aproximadamente la mitad de la altura anterior (97 dp), sin
reducir los objetivos táctiles por debajo de 48 dp. Las etiquetas mantienen
11 sp en una línea con elipsis y tooltip del nombre completo. Al ampliar el
texto, crece la barra para evitar recortes. El margen seguro de Android se
conserva y no se incluye en esta reducción.
Deslizar sigue sin cambiar la selección real ni navegar.

Los originales PNG y sus prompts de imagegen están en
output/imagegen/papercraft-navigation/. Solo assets/themes/manga/navigation/
está registrado en pubspec: cinco WebP RGBA de 256 × 256, calidad 85 y alfa
preservado (unos 68 KiB en total). Cada Image.asset limita su decodificación a
256 × 256, comparte el ImageCache estándar de Flutter y aísla repintados con
RepaintBoundary. Las cinco imágenes decodificadas ocupan aproximadamente
1.25 MiB de píxeles; no se precargan originales ni se crean caches persistentes.
Flutter administra la expulsión del ImageCache. Si falla un asset, el icono
semántico equivalente conserva una acción visible. Las etiquetas siguen usando
las traducciones existentes. Los demás temas y el engine del overlay no cargan
esta navegación. Las imágenes son decorativas en Semantics para no duplicar
el nombre del botón.

Los tests de la tira verifican altura compacta, jerarquía, área táctil y ausencia
de Jugar. El lanzamiento y su guía siguen cubiertos por how_to_play_test y los
tests del servicio. Formato, análisis y pruebas Flutter de este ajuste quedan
pendientes en CI: Flutter/Dart no están instalados en Termux. La build verde
citada arriba corresponde al diseño anterior, no a este ajuste.

## Arranque

`lib/main.dart` configura orientaciones, downloader, Hive, información de versión, eventos de instalación y el puente del overlay. Después crea el árbol Riverpod y `MaterialApp.router`.

Existe una segunda entrada, `overlayMain()`, usada por `floaty_chatheads`. Este engine no comparte memoria estática con el engine principal. La comunicación se realiza con `FloatyChatheads.shareData`/streams y el estado persistente debe viajar por almacenamiento o canales, nunca por la suposición de memoria común.

## Datos y persistencia

- Los catálogos iniciales viven en `assets/db/`.
- `db/` contiene las copias publicadas que consumen las actualizaciones remotas.
- Hive guarda preferencias de interfaz y favoritos usados por providers.
- SharedPreferences guarda flags que también necesitan servicios/puentes, como `auto_install_mods`.
- El plugin Kotlin guarda las URI SAF (`tree_uri`, `dynos_tree_uri`) en sus propias SharedPreferences nativas y conserva permisos persistentes del árbol.
- `BackgroundInstallService` mantiene una vista en memoria de trabajos activos; WorkManager sigue siendo la autoridad para su ejecución.

Las operaciones nuevas usan una identidad de dominio versionada:
`contentKey = v1|section|contentId` y
`artifactKey/operationKey = contentKey|artifactId`. El `artifactId` prioriza
IDs estables de la fuente y utiliza un SHA-256 determinista cuando el catálogo
no los publica. Título, filename, URL, posición en un array y destino son
metadata, no identidad. La metadata viaja por SharedPreferences, MethodChannel,
ambos Workers, reconciliación y EventChannel. Las operaciones antiguas sin este
contrato todavía pueden restaurarse usando su `modName` legacy, pero nunca se
convierten por aproximación en una identidad nueva.

Después de una instalación automática confirmada, el Worker escribe un recibo
JSON por `artifactKey` en almacenamiento privado. El recibo contiene identidad,
destino lógico, snapshot de presentación y un manifiesto de hasta 32 archivos
centinela; no contiene la URI SAF ni la URL de descarga. Se reemplaza de forma
atómica antes de que WorkManager publique `SUCCEEDED`, por lo que no depende de
que alguno de los dos engines Flutter permanezca vivo.

Al iniciar, `InstallationLibraryRepository` solicita a Kotlin una instantánea
validada. Los recibos dañados o de esquema desconocido se aíslan sin impedir
leer los demás. Hive usa una caja exclusiva `installation_library_v1` como
proyección reconstruible para ordenar y consultar; nunca sustituye al recibo
nativo. Los recibos se deduplican por `artifactKey`, el historial por UUID del
Worker y ambos se ordenan por fecha UTC. Riverpod expone la carga como estado
asíncrono listo, parcial o fallido y vuelve a sincronizar tras instalaciones o
cambios de carpeta. Un coordinador de proceso mantiene Hive actualizado aunque
la pantalla de Biblioteca todavía no se haya construido.

La presencia actual se resuelve por separado mediante un verificador SAF
nativo. Solo consulta las rutas centinela del recibo, serializa los lotes y
reutiliza directorios resueltos; no escanea recursivamente las carpetas en cada
render. Sus estados `present`, `missing`, `unknown` y `permissionRevoked` son
una proyección reemplazable en Hive v2. SAF es la autoridad de presencia; el
recibo y el historial sobreviven a una carpeta cambiada o permiso perdido.

`InstallationActionSelector` es la política única que combina estas fuentes
con WorkManager y la versión solicitada por el catálogo. Una operación activa
siempre gana; `Instalado` requiere recibo más SAF presente; y `Actualizar` solo
se ofrece cuando una comparación numérica conservadora demuestra que el
catálogo es posterior. Los widgets renderizan la decisión y no reconstruyen
esta lógica localmente.

La fase de mantenimiento añade `InstallationVersionPolicy`: solo ordena
versiones numéricas punteadas y usa igualdad textual normalizada como fallback
sin atribuir precedencia a etiquetas arbitrarias. El índice de catálogo de
Biblioteca reutiliza las identidades canónicas de todas las secciones y omite
una actualización cuando no puede elegir con seguridad entre varios archivos.

Kotlin clasifica una instalación confirmada como `reinstall` si reemplaza el
mismo `artifactKey`, `update` si otro artefacto del mismo contenido tiene una
versión demostrablemente anterior, o `install` en los demás casos. Los recibos
anteriores sustituidos permanecen durables y conservan sus centinelas para
propiedad/descubrimiento; el recibo sustituto guarda esa relación incluso al
reinstalarse, pero la instantánea pública expone solo los activos. El historial
los presenta como reemplazados. Olvidar un contenido o retirar un
evento elimina únicamente metadata privada: ningún método de mantenimiento
borra archivos SAF.

El overlay consume esa misma política sin abrir Hive ni asumir memoria
compartida. Cada actualización del repositorio se anuncia en el engine
principal mediante un bus de invalidación que no conserva autoridad; el
`OverlayBridge` serializa una proyección versionada por el canal de
`floaty_chatheads`. El segundo engine mantiene únicamente la última respuesta
válida según `requestId`. Recibos nativos, SAF y WorkManager continúan siendo
las fuentes de verdad.

Los mods locales previos o copiados por fuera de SM64CDPY aparecen en la misma
vista Mods del juego que los descargados por la app. `GameModActivationStore`
enumera únicamente unidades válidas según el juego: Lua inmediato o carpeta
inmediata con `main.lua`. La identidad de activación procede del nombre físico;
`LuaModMetadata` aporta autor, categoría, descripción y versión informativa desde
el mismo encabezado limitado. Metadata no crea recibos ni identidad de catálogo.
No se ofrece una pestaña Detectados ni un segundo escaneo de descubrimiento al
entrar/refrescar Biblioteca, cambiar carpeta u olvidar un recibo. La caché legacy
no se adjunta a las instantáneas de recibos. El endpoint/modelo de descubrimiento
anterior permanece para compatibilidad técnica, sin consumidores visuales.
DynOS/Touch conservan su contrato independiente `dynos-pack:` con switches propios en Biblioteca.

La pantalla Jugador reutiliza esa misma autoridad nativa y el mismo bloqueo SAF
para leer y modificar las claves `coop_player_*` de `user/sm64config.txt`. Un
digest del documento actúa como revisión compare-and-swap: si el juego u otra
función cambia el archivo después de la lectura, la aplicación rechaza la
escritura y solicita refrescar. Nombre y ocho colores se confirman en una única
transacción con el respaldo común de la activación de mods. El modelo 0..4 forma
parte de esa misma transacción. Riverpod conserva
por separado el perfil confirmado y el borrador, por lo que sliders y presets
actualizan la vista previa sin I/O nativo. Las paletas incluidas son de solo
lectura; las personales usan el formato real `[PALETTE]` en `user/palettes`.
Cambiar la carpeta unificada invalida tanto la proyección de mods como la de
Jugador. La vista previa es un PlatformView Android con WebView local y WebGL:
reconstruye el modelo desde `libmain.so` de SM64CoopDX y la ROM USA autorizada,
actualiza los uniformes de paleta sin generar PNG y libera el contexto al salir.
El contrato completo está en [PLAYER_3D_RENDERER.md](PLAYER_3D_RENDERER.md).

## Navegación y estado

GoRouter define un `ShellRoute` para las pantallas principales y una ruta de detalle fuera del shell. Riverpod administra catálogo, filtros, paginación, favoritos, tema e idioma.

## Temas incluidos — rama custom-themes

Implementado el 2026-10-13; pendiente de Actions y matriz física. Ajustes separa
el diseño incluido (Retro Manga, Mario 64 o SM64 Intro) del modo
claro/oscuro/sistema. `AppearanceNotifier` es el único escritor de `theme_id` y
`theme_mode` en Hive y publica una selección confirmada solo tras guardar.

`AppThemeDesign` y `AppThemeCatalog` definen paletas, formas, tipografía y
tratamientos semánticos de fondo, superficie y selección. `RetroTheme` conserva
la API de acceso y ahora es una ThemeExtension; los widgets Material y los
personalizados comparten tokens. `ThemeBackdrop` y `surfaceDecoration()` aplican
la interpretación N64 en puntos centrales. Los recursos originales opcionales
se importan localmente y se resuelven exclusivamente para Mario; el APK no los
incluye. Algunas composiciones Mario utilizan marcos y contadores específicos.
MaterialApp y las barras leen la variante efectiva. No se recrean router ni
providers de operaciones por cambiar de diseño.

La raíz del overlay produce su ThemeData desde `RetroTheme.overlay()` y conserva
su política oscura fija, sin Hive ni mensajes nuevos de tema. El inventario de
cada Dart, el flujo y el procedimiento para añadir diseños están en
[cuatom_themea.md](../cuatom_themea.md). No se modificó Android nativo.

## Límites importantes

1. El proceso o cualquiera de los engines puede ser recreado por Android.
2. Las variables estáticas no sincronizan el engine principal y el overlay.
3. Dos instalaciones pueden ejecutarse en paralelo; nombres de trabajo, archivos temporales y notificaciones derivan de la identidad de artefacto/UUID, no del título.
4. Una URI SAF puede perder permisos y debe revalidarse antes de escribir.
5. Los eventos en memoria no sustituyen el estado persistido de WorkManager.

El checklist obligatorio para cambios de estado compartido está en [`../AGENTS.md`](../AGENTS.md).

### Presentación compartida de Ajustes

Los selectores de tema, modo e idioma reutilizan `SettingsExpansionGroup` y
`SettingsSelectionOption`, con animaciones de giro/expansión 200/220 ms. Mario 64
habilita superficies suaves únicamente en Ajustes mediante `softSettingsPanels`;
Retro mantiene su estilo. `LocaleSelector` espera el setter de idioma existente
antes de cerrar y controla loading local sin crear otra fuente persistente.

## Activación de mods — release 1.8.3

Biblioteca incluye una sección de unidades Lua del juego con switches de selección
para el próximo inicio. SAF autoriza `user`; el servicio nativo conserva ajustes,
comprueba identidades/incompatibilidades/tamaño, crea respaldo y verifica la escritura.
DynOS/Touch mantienen su directiva separada `dynos-pack:` dentro de Biblioteca. La validación física está pendiente.
Plan, archivos, estados y matriz: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md).
Ambos workflows ejecutan también `:app:testReleaseUnitTest`. Esta implementación se publicó con 1.8.3.

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

La generación privada v3 del tema conserva además un segmento Mario para
compatibilidad con generaciones importadas. Ya no alimenta la pantalla Jugador:
el rasterizador de pose fija y su caché PNG fueron retirados. Jugador usa la
biblioteca instalada del juego, la ROM autorizada y el renderer WebGL descrito
en [PLAYER_3D_RENDERER.md](PLAYER_3D_RENDERER.md).

## Conexión unificada del juego

Rama `unified-game-folder` basada en `custom-themes`: user como raíz autorizada,
mods y dynos/packs derivados y ROM detectada sin otra selección. Contrato,
migración, resolver de documentos SAF y matriz: [UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md).
Validación Actions pendiente; revisión física requerida.

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


## Rendimiento de Biblioteca — trabajo 1.8.4

La vista de mods y DynOS conserva un snapshot reciente en Riverpod y lo
reutiliza al alternar pestañas; al volver a montar el panel se revalida si supera
30 segundos. Reanudar con el panel activo, instalar, cambiar carpeta o refrescar
manualmente también actualiza el estado. Los recibos se cargan al visitar
Instalados/Historial y el catálogo remoto al entrar a Actualizaciones. Tras la
confirmación del usuario, el switch refleja el cambio inmediatamente y las
escrituras se encolan sin bloquear las tarjetas; Kotlin valida el objetivo,
preserva `sm64config.txt`, verifica los bytes y devuelve
una confirmación pequeña sin recorrer otra vez toda la biblioteca. Ante error,
la UI recupera el último estado confirmado y avisa. Matriz y límites SAF:
[LIBRARY_PERFORMANCE.md](LIBRARY_PERFORMANCE.md).

Desde 1.8.6 la proyección de Mods del juego/DynOS también se conserva en Hive.
Al abrir Biblioteca se presenta ese snapshot sin esperar el recorrido SAF y se
reconcilia silenciosamente con `sm64config.txt` y las carpetas del juego. La
respuesta nativa verificada reemplaza y vuelve a persistir la proyección; si la
verificación en segundo plano falla, el último estado confirmado permanece
visible. Conectar, desconectar o cambiar la carpeta del juego elimina la caché
antes de invalidar el provider. El archivo del juego continúa siendo la fuente
de verdad y Hive nunca autoriza una escritura.

## Acento accesible de Retro Manga

`retroAccentProvider` es el único escritor de `retro_manga_accent` en la caja
Hive de ajustes. Publica el color después de confirmar la escritura y rechaza
escrituras simultáneas. Una clave desconocida o ausente conserva cian; cambiar de
diseño o brillo no borra la selección. `SM64CoopDXApp` conecta el valor a los dos
ThemeData. `RetroTheme` aplica el acento solamente a `retro_manga`; colores
semánticos, marcas y el engine independiente del overlay conservan sus roles.
El selector expandible incluye nombre, muestra de color y marca de selección.
En claro, los textos destacados se ajustan a contraste 4,5:1 sobre las tres
superficies neutras; los rellenos pastel mantienen tinta oscura en ambos modos.
El cache de colores de texto deriva exclusivamente del acento y las superficies:
no guarda preferencias y una combinación distinta produce otra clave.

## Decoración japonesa por diseño

`RetroTheme.showJapaneseDecorations` permite subtítulos japoneses únicamente
cuando el ID es `retro_manga`. SectionKicker, el drawer y las leyendas de
catálogo/VIP/DynOS/Touch Controls/OMM/Render96/enlaces/ajustes usan esta regla.
Se oculta también el espacio de las leyendas independientes; el contenido de
mods y los nombres proporcionados por usuarios o autores no se filtran.

## Superficies coherentes de Retro Manga

Retro Manga deriva su acabado de una política compartida en `RetroTheme`, no de
condiciones repetidas por pantalla. Las superficies neutras que pasan por
`gameDecoration` completan borde de tinta y sombra dura cuando la pantalla no
los especifica; `surfaceDecoration` sigue siendo el contrato para tarjetas
principales. `ThemeData` aplica la misma geometría rectangular a campos,
diálogos, menús, chips, botones segmentados, switches, checkboxes, sliders,
barras de progreso, pestañas, `ExpansionTile`, tooltips y botones estándar,
incluidos sus estados de foco, error y deshabilitado. Los títulos de sección
usan una etiqueta inclinada con borde, aplican `displayLabel` y truncan de
forma controlada las etiquetas largas; los grupos del drawer, de Ajustes y de
Save Files comparten el mismo tratamiento de papel/cartón. Los overrides
locales de diálogos, guía, detalle, Player y tarjetas de descarga ya no anulan
el borde o la sombra del tema.

La política solo se activa para el diseño `halftone + flat`: Minimalista no
recupera contenedores ni sombras y Minish Cap, Mario Kart 64 y los diseños N64
conservan sus tratamientos propios. `popupMenuTheme` y los controles cómic se
declaran dentro del bloque `usesComicSurfaces`, por lo que no alteran los otros
diseños. Las sombras siguen sin desenfoque y el fondo de semitono permanece
aislado en `RepaintBoundary`, evitando shaders, blur o nuevos recursos raster
durante el scroll.

## GameTool Save File

The main engine projects GameSaveStore through gameSaveProvider. Native Kotlin
owns byte-order-aware EEPROM parsing, document identity/revision checks, private
backups and verified SAF writes. Original-game semantics and lifecycle contracts
are documented in [GAME_SAVE_FILE.md](GAME_SAVE_FILE.md). Overlay has no save editor.

## Drawer navigation groups

`AppDrawer` groups exploration, game tools, exclusive content and resources using
a shared themed header. `currentRouteProvider` remains the navigation projection
written by AppShell and read by the drawer; entering a child route expands and
highlights its group. Group expansion is independent local UI state, remembered
by PageStorage for its existing navigation lifetime, not durable user settings or
a cross-engine cache. Home and Settings stay direct links. No routes, Workers,
SAF grants or overlay messages change.

Drawer root links use the same themed heading size, icon bounds and minimum row height as group headers. Nested destinations keep body typography. The navigation caption uses a compact single-line body label instead of the shared decorative section heading, so narrow drawers do not split it. Exclusive uses a collection icon; Render96 uses a distinct 3D-model icon in every theme.

Optional accelerated installation selects a contained direct writer for eligible primary-storage document destinations with all-files access. SAF remains the fallback and folder grant remains required. ZIP, 7z and loose files share one sink abstraction; permission is read from Android per operation. See FAST_INSTALLATION.md for platform boundaries, cache invalidation and rollback limits.
