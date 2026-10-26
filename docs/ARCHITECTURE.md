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

## Menú flotante bajo demanda — menu-slide, 2026-10-21

Rama creada desde drawer-ui (76101bf). AppShell conserva el Scaffold y sus
pantallas, pero MangaNavigationDock coloca por encima el botón Menú fijo en
la esquina inferior derecha, con margen seguro. El dock existe solo en Retro
Manga; los otros cinco temas conservan su drawer.

El estado inicial es cerrado. Pulsar el botón abre o cierra el carrusel anclado
al borde inferior. El botón sube al abrir para quedar 28 dp por encima del
carrusel, dejando libre el icono central elevado; al cerrar vuelve a la esquina
inferior derecha. Ambas posiciones respetan el margen seguro de Android. La tira mantiene sus cinco grupos,
assets, colores, etiquetas, selección y protección de borradores de Jugador.
La navegación confirmada, incluso elegir la ruta actual, cierra el dock;
cancelar un diálogo de borrador o un panel de destinos lo mantiene accesible.
Atrás cierra primero el dock sin navegar, excepto si hay un modal encima: en
ese caso el modal recibe Atrás. Se usa BackButtonListener bajo MaterialApp.router:
https://api.flutter.dev/flutter/widgets/BackButtonListener-class.html.

La apertura combina desplazamiento vertical corto y opacidad durante 180 ms;
el cierre dura 130 ms. El botón usa el mismo progreso para elevarse, cruzar
su imagen de tres puntos a X y aplicar una compresión sutil, sin tickers extra. No se anima el layout completo de la pantalla ni se
usan blur, shaders o recursos nuevos. Con reducción de movimiento se aplica
el estado final sin transición. La tira se construye al primer uso; después
Offstage, IgnorePointer, ExcludeSemantics y TickerMode la retienen sin acciones
ocultas ni animaciones activas. El PageController se conserva al alternar el
botón y se desecha con el dock. CurvedAnimation, AnimationController y el
observer de ciclo de vida se retiran en dispose.

El botón conserva un objetivo mayor de 48 dp, un nombre localizado de acción
y estado toggled para accesibilidad. Usa dos badges azules con borde blanco
inspirados en Mario Run, con sombra del acento del usuario. Son WebP RGBA de
192 × 192; la decodificación está acotada a ese tamaño (288 KiB de píxeles en
total para ambos) y conservan fallback de icono si falla el asset. Los PNG
originales y prompts del generador integrado imagegen están en
output/imagegen/mario-run-menu-buttons/, fuera del bundle. Permanece visible encima del teclado; la llegada del
teclado cierra un panel ya abierto. Abrir explícitamente el menú quita el foco
del campo. Pausar u ocultar la aplicación cierra el panel sin persistirlo.

MangaNavigationScope publica reservedBottomInset calculado por el dock desde
texto, panel abierto/cerrado, teclado y SafeArea. Los footers y padding de las
listas leen ese valor en vez de asumir un bottomNavigationBar permanente.
La pantalla conserva su viewport completo; el margen final protege el botón
y, cuando está abierto, también el carrusel y su icono elevado. No hay cachés
persistentes, preferencias nuevas ni sincronización con el engine del overlay.
GoRouter sigue siendo la autoridad de ruta; el dock solo controla visibilidad.
Las TickerFuture de las transiciones se inician intencionalmente sin await;
no se añade ningún Future de IO ni se modifica la coordinación de operaciones.

Tres claves nuevas en cinco ARB (mangaMenuLabel/Open/Close). Regenerar con
flutter gen-l10n; los Dart generados no se editan manualmente. Pruebas añadidas:
arranque cerrado, tira al borde inferior, cierre elevado sin solapamiento,
área táctil, abrir/cerrar con Atrás, retención
del controlador, reducción de movimiento, Semantics y prioridad de modales.
La matriz existente abre ahora el dock explícitamente y comprueba que se
cierra tras elegir un destino. Formato, análisis, tests Flutter y validación
física siguen pendientes: este Termux no dispone de Flutter/Dart.

### Corrección de Testing 39687239343

El análisis pasó y 436 pruebas Flutter terminaron correctamente; falló únicamente
first-run decisions appear as two sequential dialogs. Su fixture usaba
MaterialApp.home, sin Router, aunque AppShell ahora contiene BackButtonListener.
La aplicación real y las pruebas del dock sí usan MaterialApp.router/GoRouter.
Se actualiza el fixture a GoRouter + ShellRoute, manteniendo las aserciones del
orden de los diálogos, confirmación de persistencia y ausencia de excepciones.
No se cambia la lógica de auto-install ni se omite el control de Atrás del dock.
Las traducciones generadas y el formato del código del menú se sincronizan desde
el artefacto flutter-source-sync de esa ejecución. Hace falta repetir CI para
validar la corrección; no hay Flutter/Dart instalado en este Termux.

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
hamburguesa únicamente bajo la navegación inferior real. Scaffold extiende
el viewport detrás de la tira y la oculta con el teclado; el margen seguro
queda en la propia navegación y al final de las listas. AnimatedScale
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
La superficie de la tira usa retro.background con alfa 0.85 (15 % transparente),
crema en claro y tinta en oscuro, para mejorar legibilidad sin blur.
AppShell usa extendBody solo para
Retro Manga. Diagnóstico de las dos capturas: un SafeArea global seguía
recortando el viewport al comienzo de la tira; se veía una franja de fondo
vacía aunque Material fuera transparente. Ese SafeArea se retira.
Las listas CustomScrollView añaden MangaNavigationSliverInset al final;
Favoritos, Aviso legal, skeleton de Inicio y Preparar ROM ajustan su padding
interno. El helper usa el padding inferior de MediaQuery que Scaffold amplía
con la altura real de la navegación, más 24 dp para el icono elevado. Es espacio
desplazable, no una franja fija: el viewport llega detrás del menú y el último
control puede desplazarse por encima de los iconos. Fuera de Manga o con
teclado devuelve cero. No se modifican datos, operaciones ni scroll controllers.
La guía conserva su zona segura local para sus botones fijos Anterior/Siguiente;
no se cambia su estructura paginada por una lista continua. Los demás temas
conservan el drawer y sus dimensiones. No se usa blur ni capa oscura.
Pruebas de regresión: viewport completo, superficie semitransparente adaptada al tema y última
acción accesible al final, en ambos modos. Sigue pendiente ejecutar Flutter/CI.
Cada etiqueta lleva una cápsula redondeada con borde blanco fino y gradiente
azul en oscuro (#2387FF) o rojo en claro (#E53935). Los tres tonos del reflejo
usan alfa 0.35: 65 % de transparencia, sin capa opaca bajo el gradiente.
Sugiere una burbuja de jabón sin otra caja alrededor del icono. El relleno amarillo y el contorno negro son iguales
en ambos modos. El halo y el subrayado conservan el acento personalizado.
Los cinco iconos papercraft flotan sin cajas, divisores ni borde superior. Solo
la imagen se escala: el icono centrado llega a 2 (52 dp, el doble de sus 26 dp base) y sus vecinos
a 0.62 (unos 16 dp). AnimatedBuilder observa el PageController y calcula la
escala por distancia al centro en cada fotograma, sin reconstruir el shell ni
navegar. El icono centrado se eleva 11 dp, crece por encima de la tira y
no cubre la etiqueta; este saliente es decorativo, la acción táctil permanece
en la celda de al menos 48 dp. La altura reservada de la barra no aumenta.
Un halo elíptico con sombra corta usa retro.accent del ThemeExtension
vigente; no mantiene copia local del color. Ajustes escribe la preferencia de
acento existente y main reconstruye el tema, que actualiza este consumidor.
Al reducir movimiento, el énfasis cambia al centro sin interpolación adicional.
La etiqueta subrayada y Semantics.selected siguen indicando la ruta abierta,
aunque se explore otro grupo. Las cinco etiquetas del carrusel y el rótulo Menú del botón reutilizan
headingFontFamily de mario64Theme (TypefaceMario64), sin cambiar el tema
global ni los paneles.
Dos Text superpuestos dibujan relleno amarillo y contorno negro de 1.5 dp
en ambos modos. Una única Semantics excluye las dos capas
para evitar anuncios duplicados. La ruta abierta conserva el subrayado de acento.
mangaNavLibrary usa Mis Mods en español solo en el carrusel; Library y
Biblioteca se conservan en inglés/portugués. La ruta /library y los títulos
de pantalla no cambian. Regenerar la nueva clave con flutter gen-l10n.
La clave mangaNavTools usa Tools / Taller / Oficina solo en la tira;
mangaNavMore usa MAS sin tilde en español solo en este menú.
mangaNavExplore usa Mods en español (Explore / Explorar en inglés/portugués),
sin cambiar los títulos de sección ni el panel de destinos.
el título completo Herramientas y sus equivalentes sigue en el panel.
Regenerar localizaciones con flutter gen-l10n antes del análisis o compilación;
no se editan los Dart generados manualmente.
La barra ocupa aproximadamente la mitad de la altura anterior (97 dp), sin
reducir los objetivos táctiles por debajo de 48 dp. Las etiquetas mantienen
11 sp como tamaño base, con FittedBox.scaleDown para conservar todas las
letras en una línea, sin elipsis. Ambas capas de fuente usan el mismo ajuste.
Con escala accesible mayor que 1.3, se habilitan dos líneas y crece la barra.
El tooltip y Semantics conservan el nombre completo. El margen seguro de Android se
conserva y no se incluye en esta reducción.
Deslizar sigue sin cambiar la selección real ni navegar.

El conjunto cartoon-v2 toma mods.png del usuario como referencia: colores
facetados, contorno negro grueso y borde blanco de papel recortado. Mods usa
el grupo de gorras/champiñón; Inicio usa un champiñón rojo simple (v3),
sin casa ni facetas, y Taller las herramientas,
Mis Mods una carpeta con tarjetas de juego y MAS el bloque de interrogación.
Los PNG originales y los prompts del generador integrado imagegen están en
output/imagegen/cartoon-navigation-v2/ y output/imagegen/home-simple-v3/
(solo material local, fuera del APK).
El original de Mods tenía fondo negro opaco: se conserva aparte y se genera
un recorte transparente antes de la conversión. No se afirma equivalencia
píxel a píxel con la referencia tras la edición generativa.
Solo assets/themes/manga/navigation/ está registrado en pubspec: cinco WebP
RGBA de 256 × 256, calidad 88, método 6 y alfa de calidad 100.
El conjunto ocupa 102.4 KiB. explore.webp conserva su ruta histórica, pero
ahora contiene el icono de Mods; no se altera el agrupamiento de navegación.
Los cinco archivos sustituyen a los anteriores sin duplicarlos en el bundle. Cada Image.asset limita su decodificación a
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

### Legibilidad del carrusel — 2026-10-21

La captura de Mis Mods mostraba MIS MO… porque TextOverflow.ellipsis truncaba
el texto en el 32 % de ancho asignado a la celda. No se cambia el nombre ni se
sustituye la fuente: un ajuste compartido mantiene el texto completo y dos
líneas para texto ampliado. Las pruebas comprueban que el párrafo queda dentro
de la burbuja en 320 px y horizontal, además del alfa/color del fondo en ambos
modos. Pendiente ejecutar Flutter/CI y revisar físicamente la nueva superficie.

### Ajuste de coherencia del dock — 2026-10-21

La captura mostraba una fila vacía debajo del carrusel por apilar la tira y el
botón en una Column. Ahora son dos capas Positioned independientes: la tira
mantiene su posición inferior y el cierre cambia su posición real por encima
de ella. Así su zona pulsable coincide con la X, sin quedar fuera de los
límites de hit testing de su padre.
El margen desplazable protege el conjunto completo mientras está visible.
Los nombres de una sola palabra, como EXPLORE, se ajustan en una línea incluso
con texto ampliado, para no separar la última letra en otra fila. Solo las
etiquetas con espacios permiten dos líneas accesibles. El controlador de
animación, el PageController y las reglas de cierre/cancelación se mantienen.
Pendiente validar este ajuste con Flutter/CI y físicamente en claro/oscuro.

### Rótulo Menú multicolor — 2026-10-21

El botón conserva su nombre localizado y usa TypefaceMario64 en mayúsculas.
Cada letra recibe azul, rojo, amarillo o verde, inspirado en el título de
Mario 64. Un contorno negro de 1.5 dp mantiene la silueta y, en oscuro, un
filete blanco exterior de 2.8 dp la separa del fondo. Text.rich dibuja el color
y Text con Paint.stroke el borde; no se crean bitmaps, shaders ni tickers.
FittedBox evita recortar el rótulo dentro del botón y respeta el espacio
reservado a su caption. El botón sigue anunciando una sola acción localizada
Abrir/Cerrar menú mediante su Semantics superior. Tests de familia, texto
español, colores y contorno claro/oscuro añadidos; ejecución Flutter pendiente.

### Cierre compacto del menú flotante — 2026-10-21

Con el carrusel abierto se oculta el rótulo Menú y el badge de cierre pasa
de 56 a 28 dp mediante el controlador existente. El área táctil conserva
su tamaño (mínimo 48 dp), tooltip y semántica localizada. Al cerrar vuelve
el rótulo multicolor; no se añaden estado persistido, caches ni animadores.

### Temas disponibles — 2026-10-21

El selector ofrece únicamente Minimal, Retro Manga y Mario Kart 64. Los IDs
persistidos `mario64`, `sm64_intro` y `minish_cap` se interpretan como Retro
Manga desde `AppThemeId.fromStorage`; `AppearanceNotifier.setTheme` aplica
la misma normalización antes de guardar. El modo claro/oscuro/sistema y el
acento se conservan. No se escribe en Hive durante un build: la selección
antigua se normaliza al leer y se reemplaza al siguiente guardado de apariencia.

Se conservan definiciones internas retiradas para las pruebas de compatibilidad
y los helpers compartidos; no forman parte de `AppThemeCatalog.designs` ni se
pueden activar por el provider. TypefaceMario64 sigue disponible para los
rótulos del menú de Retro Manga. No cambia el engine del overlay, que mantiene
su paleta independiente; no se añaden caches, Futures sin esperar ni canales.

### Transición tipográfica entre temas — 2026-10-21

Los estilos de botones de racing y folio usan `inherit: false`, igual que los
estilos completos de Material y Retro Manga. Esto permite interpolarlos sin
aserciones de `TextStyle.lerp` al cambiar de diseño. Se comprueban los cuatro
tipos de botones entre todos los diseños disponibles en claro y oscuro.

### Audio del menú Retro Manga — 2026-10-21

`MangaMenuAudioPlugin` se registra solo en el engine principal. SoundPool
precarga los dos efectos de `assets/audio/manga/`, mantiene una sola voz y limita
emisiones a una cada 75 ms. Usa audio de juego (`USAGE_GAME`) al 65% del volumen multimedia
correspondiente, sin permisos, foco de audio exclusivo ni servicio de fondo.
Un sample no preparado se omite; no se encolan reproducciones tardías.
El pool y el listener se liberan al destruir el engine.

`MangaMenuAudio` encapsula MethodChannel y captura fallos de plataforma. El dock
reproduce press al pulsar abrir/cerrar; la barra al pulsar un grupo o destino.
PageView emite slide cuando cambia la página central durante un desplazamiento,
no en cada frame ni al sincronizar la ruta. Los cierres automáticos no añaden
sonido. Pausa/inactividad y desmontaje del dock detienen las voces.

`manga_menu_sounds` en Hive es la fuente persistente, con valor predeterminado
activado. `MangaMenuSoundsNotifier` es el único escritor y publica tras guardar;
si falla conserva el valor anterior. Cada reproducción consulta este estado y
el tema actual. Ajustes muestra el switch solo para Retro Manga, usando los
cinco ARB. El overlay no registra el plugin ni comparte esta preferencia.
Los Futures de efectos y parada son intencionalmente no esperados para no
bloquear navegación; el servicio captura sus errores. No se añaden timers ni
cache de preferencias independiente: solo samples nativos por vida del engine.

Validación física pendiente: primer toque, arrastre rápido, silencio/volumen,
switch apagado, reabrir app, cambiar tema y minimizar. CI debe generar l10n,
formatear, analizar, ejecutar pruebas y compilar Kotlin antes de probar el APK.

### Corrección de pruebas tras retirar temas — Actions 39730665442

La regresión tipográfica se comprueba con botones reales (Filled, Elevated,
Outlined y Text), conservando sus elementos al cambiar entre cada par de temas
disponibles, en claro y oscuro, y verificando frames intermedios. No se compara
`labelLarge` incompleto contra un estilo completo: Material debe resolver sus
valores predeterminados y combinarlos antes de la interpolación.
La prueba de idioma identifica sus cuatro grupos por clave, incluyendo acento,
en vez de asumir el antiguo total de tres. Los dos fallos de esta ejecución son
anteriores a la integración del audio; nueva ejecución de CI pendiente.

### Audio inaudible: diagnóstico del APK — 2026-10-22

Se inspeccionó el APK del Actions 39731678882 (`87fdff3`): ambos efectos están en
`assets/flutter_assets/assets/audio/manga/`, almacenados sin compresión. Por ello
no es necesario cambiar pubspec ni añadir reglas noCompress. El WAV es PCM mono
16 bits/32 kHz, 0,401 s, con señal no silenciosa. La preferencia y los eventos
sí llegan al servicio por el flujo existente.

Se reemplaza `USAGE_ASSISTANCE_SONIFICATION` (sonidos del sistema) por
`USAGE_GAME` (volumen multimedia): la política de volumen del sistema puede
silenciar el primero independientemente del volumen multimedia. MainActivity
selecciona STREAM_MUSIC para las teclas de volumen, sin alterar el nivel elegido
por el usuario. Esta es una causa probable: no se pudo confirmar el estado del
mezclador del teléfono porque adb local no inicia por incompatibilidad de libs.

Carga rechazada, error de decodificación, excepción de asset y reproducción
rechazada se registran con tag `MangaMenuAudio`; el bridge Dart también registra
fallos del canal. No se bloquea la UI, no hay audio diferido ni reintentos
automáticos. Se mantienen mute persistente, parada por lifecycle y aislamiento
del overlay. Pruebas comprueban assets y payloads press/slide del canal; CI y
escucha en dispositivo siguen pendientes tras la corrección.

Referencias: https://source.android.com/docs/core/audio/attributes y
https://developer.android.com/reference/android/content/res/AssetManager#openFd(java.lang.String).

### Mezcla interna de audio — 2026-10-22

`AppAudioSettings` / `appAudioSettingsProvider` definen la mezcla interna con
`effectsVolume` (0–1). Hive `audio_effects_volume` es su fuente persistente;
valor ausente/corrupto/no finito usa 0,65 para conservar el volumen anterior.
El notifier limita valores, serializa el guardado rechazando otra escritura
concurrente y publica únicamente tras persistir. Si falla conserva el valor
confirmado. El booleano `manga_menu_sounds` sigue separado: mover volumen no
reactiva un canal silenciado y desactivar sonidos conserva el nivel elegido.

El slider Manga mantiene un borrador local mientras se arrastra, guarda una
sola vez al soltar, bloquea otra edición hasta terminar, revierte si falla y
reproduce una única muestra con el nivel confirmado (si el canal está activo).
No escribe Hive ni manda IPC por cada frame. Al desmontar se descarta el
borrador; el guardado iniciado conserva su propietario provider y la UI no usa
context tras el await sin comprobar mounted.

Cada efecto consulta el nivel confirmado y lo envía como `volume` junto con
`sound` por el canal existente. Kotlin limita otra vez el valor, lo aplica a
ambos canales de SoundPool y omite ganancias cero. No guarda una segunda copia
del mezclador ni toca `setStreamVolume`/volumen global. La ganancia final sigue
limitada por el volumen multimedia de Android. Los botones físicos conservan
el comportamiento estándar multimedia; el slider es el ajuste propio de la app.
Overlay no registra este audio ni replica preferencias. Sin nuevos Futures
no esperados, timers, listeners nativos, permisos o dependencias.

La música ambiental se amplía en la sección siguiente con una pista local y
canal independiente. No se usa SoundPool para pistas largas ni se modifica el
volumen del sistema.

Pruebas: valor inicial, restauración, nivel cero, separación del mute,
normalización de valores inválidos, fallo de persistencia y ganancia por mensaje
para press/slide. Validación de CI y escucha física pendientes.
Referencia: https://developer.android.com/reference/android/media/SoundPool.

### Música ambiental y viñetas destacadas — 2026-10-22

La pista proporcionada `ambient/ambiente2.opus` se incluye sin transcodificar
como `assets/audio/manga/ambiente2.opus` (unos 371 KiB, Ogg Opus). La carpeta ya
está declarada en pubspec; Android marca opus como noCompress para openFd.
`AmbientMusicPlugin`, registrado solo en MainActivity, usa un único MediaPlayer
con prepareAsync, lectura por descriptor y bucle. No copia/decodifica toda la
pista en memoria ni crea servicios, temporizadores o nuevas dependencias.

AppAudioSettings añade `musicEnabled` (inicialmente true) y `musicVolume` (0,18).
Hive guarda `audio_music_enabled` y `audio_music_volume`; todas las escrituras
del mix preservan los otros canales y publican después de persistir. Ajustes
incluye switch y slider de música independientes de efectos en cinco ARB.
El mute de efectos no silencia música; el de música no cambia efectos.

AmbientMusicCoordinator es propietario estable bajo MaterialApp del engine
principal, escucha tema/mix y envía configure por `sm64cdpy/ambient_music`.
Cambiar de ruta no lo reconstruye como un nuevo reproductor ni reinicia pista.
Solo activa música con Retro Manga y la preferencia activa. Sus Futures no
esperados están limitados a sincronización y desmontaje; el servicio captura
PlatformException/MissingPluginException. No hay cache adicional de Hive.

Android registra callbacks únicamente para su Activity y los retira al
separarla del plugin/engine. onPause pausa y abandona foco (incluido lanzar el
juego/explorador/bloquear/minimizar); onResume reevalúa el estado. Rotación
separa/reconecta Activity conservando el único player mientras viva el engine.
Solo se solicita foco con Activity reanudada y pista preparada: AUDIOFOCUS_GAIN,
API 26+ con AudioFocusRequest y compatibilidad 24–25. Pérdida transitoria pausa,
ducking atenúa al 20% de la ganancia y pérdida permanente bloquea reproducción
hasta volver explícitamente o reactivar música. Una respuesta tardía de
prepare/foco vuelve a comprobar visibilidad y preferencia antes de empezar.
Volumen cero pausa/abandona foco. Fallos de carga se registran y no se reintentan
en bucle; apagar/encender permite un intento nuevo. Al destruir engine se
retiran listeners y se libera MediaPlayer. Overlay no registra música.

Home usa FeaturedModFrame únicamente en Retro Manga: papel, borde de tinta,
sombra dura y placa sólida con colores semánticos para título/autor/rating.
Se elimina el gradiente genérico en Manga, el corazón usa acento y objetivo de
48 dp, y se conservan Hero, favoritos y navegación. El marco es RepaintBoundary
sin animador propio; no hay blur, shaders o bitmaps decorativos nuevos.
CachedNetworkImage limita la decodificación a un máximo de 960 px de ancho;
el carrusel aumenta altura con texto accesible. Los otros temas conservan su
presentación de imagen y controles.

Pruebas añadidas para contrato/asset Opus, sincronización del coordinador,
aislamiento por tema, teardown, restauración de canales y marco claro/oscuro.
CI y validación física pendientes (latencia, bucle, llamadas/foco, minimizar,
rotar, lanzar juego, otros reproductores, texto grande y gama baja).
Referencias: https://developer.android.com/media/platform/mediaplayer/state-resources
 y https://developer.android.com/media/optimize/audio-focus.

### Submenú Audio del carrusel — 2026-10-22

Los controles se retiran de AppearanceSelector/Ajustes y se reutiliza el mismo
MangaMenuSoundSetting en un modal accesible desde la sexta viñeta Audio/Áudio.
No se duplica estado, lógica de guardado ni configuración de reproducción.
showMangaAudioMenu usa los helpers del tema, SafeArea, cabecera con cierre y
contenido desplazable limitado al 80% de pantalla. Atrás/cerrar/arrastrar cierran
solo el modal: no cambian ruta ni descartan borradores de Jugador; el dock queda
abierto. Un guardado ya iniciado conserva el flujo anterior y revisa mounted.

El PageController parte ahora de 1020 (múltiplo de seis); los índices previos
0–4 se conservan y Audio es 5. Inicio sigue centrado; sus vecinos son Audio y
Mods. Música, efectos, volúmenes, lifecycle nativo y overlay no cambian.

Icono `assets/themes/manga/navigation/audio.webp`: bocina de papel naranja/azul,
contorno de tinta y borde blanco, generación built-in imagegen con tools.webp
como referencia de estilo. Conversión con cwebp, 256×256, calidad 85 y alpha 100,
unos 19 KiB; caché de decodificación existente del carrusel limitada a 256 px.
La cabecera del modal solicita 128 px. Fuente y prompt conservados localmente
bajo output/imagegen/manga-audio-icon/ (ignorado por Git); solo WebP se publica.

Pruebas: asset WebP, centro/vecinos con seis elementos, audio en tres idiomas a
320 px/texto 1,6×, acceso a controles mediante scroll, cierre con Atrás sin
navegar y ausencia de los controles en Ajustes. SDK Flutter no disponible local;
CI y comprobación visual del menú en dispositivo pendientes.

### Marca de Home — 2026-10-22

Home muestra SM64CDPY sin la acción de lupa. Comparte MarioMulticolorLabel con
el botón Menú: TypefaceMario64, secuencia azul/rojo/amarillo/verde, contorno negro
y filete blanco adicional en oscuro. El helper conserva las claves previas del
menú y permite tamaño/prefijo propios para Home (17 px, home-brand).
FittedBox adapta el rótulo al ancho disponible; Semantics lo anuncia como un
solo encabezado, sin repetir cada capa del contorno. No hay nuevos assets,
animaciones, preferencias o cambios de navegación; el catálogo sigue accesible
desde sus entradas existentes. La marca propia no requiere traducción.

### Switches rectangulares Retro Manga — 2026-10-22

MangaSwitch sustituye las píldoras Material en Biblioteca (Game Mods, DynOS y
Touch Controls), Audio (música/efectos), Partidas (cañones/desbloqueos) y los
switches propios de Ajustes (auto-install y overlay). Riel 52×30 y selector
18×18 sin radios, usando tinta/papel del tema: apagado con contorno y selector
hueco a la izquierda; encendido con relleno de tinta y selector de papel a la
derecha. En oscuro se invierten automáticamente los colores mediante los roles
del tema, no con colores literales. Objetivo táctil 56×48, transición de 140 ms,
reducida a cero con disableAnimations; foco de teclado conserva el acento.

ThemedSwitchListTile reutiliza el control en filas con MergeSemantics y área
completa pulsable; otros temas siguen usando SwitchListTile. Biblioteca
conserva Switch/MarioGameToggle fuera de Manga y las claves por identidad.
Ajustes mantiene su diseño previo en los otros temas. El overlay no contiene
switches visuales: solo se adapta su control en Ajustes, sin cambiar engine,
preferencias ni servicios. No se cambian eventos, confirmaciones, persistencia,
optimismo o Futures de las acciones. El control representa el valor recibido y
solo solicita onChanged; onChanged nulo deshabilita semántica, foco y pulsación.

SwitchThemeData no permite sustituir la geometría circular interna de Switch;
por eso cambiar colores del tema no corregía las píldoras. Nuevos controles
Manga deben reutilizar MangaSwitch o ThemedSwitchListTile, no Switch directo.
El componente no carga assets, blur, timers o animaciones en reposo.
Pruebas añadidas para claro/oscuro, forma, contraste, pulsación, teclado,
semántica, deshabilitado y aislamiento de los temas a 320 px/texto 1,6×.
Análisis/tests Flutter y revisión física pendientes por SDK no disponible local.

### Manga Deluxe — 2026-10-22

Nuevo ID `manga_deluxe` y capacidad `AppThemeId.isManga` para compartir menú,
switches, audio y acento sin confundirlos con `showJapaneseDecorations`, que
permanece exclusivo de Retro Manga. Paleta propia y fondo en AppShell (también
en Home), con gorros/patrón optimizados, quieto por defecto y movimiento opcional
respetando lifecycle/TickerMode/accesibilidad. No se cambia el overlay.
Contenido Deluxe: bienvenida CoopDX compacta y descartable, demostración externa bajo
demanda, FAQ y enlaces del port Android. Preferencias y reset solo por escritores
canónicos. Procedencia, rutas, pruebas y límites en [MANGA_DELUXE.md](MANGA_DELUXE.md).

### Home compacto y fondo Deluxe — 2026-10-22

Home ya no busca un spotlight DNC ni necesita collection para ello. El fondo
repite gorros a 80 dp y trama a 110 dp mediante DecorationImage.scale; la
traslación usa exactamente ese período para evitar saltos. Opacidad moderada,
papel neutro al 88 %, fotos y rellenos de acciones intactos. Conserva los dos
RepaintBoundary, movimiento opcional, pausa y accesibilidad existentes.

`deluxeWelcomeHiddenProvider` lee/escribe exclusivamente la clave Hive
`manga_deluxe_welcome_hidden` del box de ajustes. Omitir espera la escritura;
si falla conserva la tarjeta y ofrece reintentar. Tras guardarse no reserva
espacio y sobrevive al proceso, navegación y reset visual/audio. Solo se lee
en Home del engine principal; el overlay no muestra introducción ni necesita
replicación. Sin timers, IO en build ni Futures nuevos sin esperar.

La prueba que importa HomeScreen real conserva cobertura de carga/error.
Las pruebas Deluxe verifican persistencia entre contenedores, fallo de guardado,
intro omitida, papel neutro y adaptación a 320 px/texto 1,6× en tres idiomas.

### Movimiento Deluxe perceptible

El período del fondo es de 12 s: 80 dp/12 s para gorros y 110 dp/12 s para
trama. El antiguo período de 60 s resultaba casi imperceptible tras reducir los
assets. Cada plano conserva sus dimensiones y se desplaza por Transform.translate
bajo recorte. Se conserva la preferencia Hive, pausa por lifecycle/TickerMode y
reducción de movimiento; sin nuevos escritores, caches ni Futures sueltos.
La prueba de conmutación mide píxeles desplazados, no solo isAnimating.

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

## Privacidad en Disclaimer — 2026-10-23

La información de privacidad de red y su botón de consulta se trasladan de Play
al Disclaimer mediante CoopNetworkPrivacyPanel. La consulta muestra los textos
localizados vigentes en un diálogo informativo, sin aceptar términos, persistir
preferencias ni iniciar una sesión. El consentimiento obligatorio previo a crear
o unirse permanece en Play con validación/persistencia existentes; se retira solo
el parámetro de revisión forzada que ya no tiene llamadores. Introducción Play
reducida de 14 a 7 sp (-50 %), conservando escalado de accesibilidad del sistema.

Sin cambios en provider, servicios, motor, Kotlin, WebView, UDP ni assets/coop.
Sin caches ni suscripciones nuevos. Pruebas verifican la ubicación de textos,
tamaño y consulta sin ProviderScope ni acceso al motor. Flutter pendiente en CI.

## Tipografía unificada Familjen Grotesk — 2026-10-23

FamiljenGrotesk (Regular 400) sustituye a SupremeSpike y SuperMarioWorldTextBox
en todos sus lectores: opciones de submenús, acciones/lectura Play y autor,
descripción, etiquetas y fechas del detalle de mod en Manga Deluxe. Una sola
familia registrada desde fonts/manga_deluxe/FamiljenGrotesk-Regular.ttf (~83 KB),
fallback Roboto. Se eliminan ambos binarios sustituidos y sus registros. Tamaños,
colores, escalado del sistema y títulos Mario multicolor permanecen intactos.
Otros temas conservan sus familias. Pruebas existentes actualizadas; sin cambios
de conexión, providers, preferencias, caches, motores ni canales Android.
Pendiente format/analyze/tests en CI por falta de Flutter/Dart local.

## Tipografía Home Manga — 2026-10-23

`HomeTypography` limita Familjen Grotesk al subárbol de Home (incluye carga/error)
en Retro Manga y Manga Deluxe. No cambia el catálogo de temas, preferencias ni
otras rutas. Featured, Browse, Recent, Exclusive Content y Top Downloads usan
`HomeMarioLabel`: TypefaceMario64 blanca, contorno negro uniforme, sin colores
por letra. Respeta escalado y saltos de línea; cabecera SM64CDPY multicolor intacta.
Launch game reutiliza el mismo rótulo e icono play.webp a 36 dp con decode 128 px,
sin nuevos assets. Su callback, comprobación del juego y bloqueo siguen iguales.
Los textos restantes heredan la fuente local, incluidas tarjetas y acciones.

Pruebas a 320 px/texto 1,6×, ambos Manga y claro/oscuro: contorno, familia,
icono y ausencia de overflow. Sin nuevos caches/estado/Futures. Pendiente
format/analyze/tests en CI y verificación física; git diff --check validado.

## Home compacto e iconos propios — 2026-10-23

Start game (Iniciar juego/Iniciar jogo) sustituye al rótulo anterior en las cinco
ARB; Exclusive se acorta a Exclusivo en ES/PT. HomeMarioLabel acepta singleLine:
letras de 14 sp en el lanzamiento, ajustadas al ancho sin salto de línea. Icono
propio de cartucho a 32 dp. Catalog/Favorites/Popular usan libro, corazón y estrella
con flecha: ilustraciones nuevas de papel/tinta generadas con imagegen, WebP
transparente 192×192, decode 128 px. Solo se incluyen los WebP finales: 4.932,
7.700, 5.192 y 7.588 bytes respectivamente (25.412 bytes en total).

Browse comparte el relieve de Featured: margen vertical 0 activo / 8 dp lateral,
250 ms easeOut y sin animación cuando disableAnimations está activo. No se añade
autoplay ni ticker permanente. _current y PageController siguen siendo estado
visual local; se libera el controlador al desmontar. Altura de tarjetas adaptable
al texto para evitar overflow al reducirse la tarjeta inactiva.

Navegación de las categorías, comprobación del juego y launchGameWithGuide no
cambian; tampoco providers, permisos, instalación, overlay ni motor Play. Pruebas
actualizadas y Home real con catálogo vacío: 320 px, texto 1,6×, ES/EN/PT, ambos
Manga, desplazamiento, foco y reducción de movimiento. Validación local JSON,
transparencia/dimensiones/peso de assets y git diff --check; pendientes gen-l10n,
dart format, flutter analyze y tests en CI por falta de SDK, más revisión física.

## Fixture Home — Actions 40032193746

flutter analyze pasó y 477 pruebas aprobaron; las seis variantes home_browse
agotaron pumpAndSettle durante el montaje inicial (línea 76 del archivo formateado
en CI). La prueba mezclaba la carga async del catálogo y la comprobación nativa
de instalación con las aserciones de presentación.

Se precargan catálogo y biblioteca falsos en un ProviderContainer explícito antes
del montaje usando runAsync y se simula isInstalled en sm64cdpy/launcher. El
handler rechaza llamadas inesperadas y se retira al terminar; el contenedor se
libera. El primer render usa pumps acotados, sin aumentar timeouts. Las pruebas
de scroll/foco/tamaño se mantienen; la prueba separada de carga/error de Home
sigue intacta. No cambia código del producto, estado compartido ni motor Play.
Pendiente repetir Flutter en CI; no hay SDK local. git diff --check validado.

## Audio de tarjetas Home — 2026-10-23

Featured y Browse emiten home_slide al cambiar realmente de página durante un
scroll activo. No se reproduce por frame, al montar/restaurar Home ni por scroll
vertical. Ambos carruseles pasan a ConsumerStatefulWidget conservando sus
PageController y animaciones. Sonido proporcionado: home-cards-slide.mp3,
19.968 bytes, aproximadamente 0,62 s; ya cubierto por assets/audio/manga/.

HomeCardSoundsNotifier es el único escritor de audio_home_cards_enabled y
audio_home_cards_volume en Hive settings (true/0,45 por defecto). Audio y ambos
carruseles leen la misma proyección; cada cambio espera persistencia y conserva
estado anterior ante fallo. Volumen acotado 0–1, valores corruptos/NaN seguros.
Sonido exclusivo de Retro Manga/Manga Deluxe, independiente de efectos del menú
y música. El submenú Audio permite apagar, ajustar y oír una muestra al soltar;
Restablecer Deluxe incluye esta preferencia. Sin IO/preview por fotograma.

El canal existente sm64cdpy/manga_menu_audio agrega stopSound(sound). Kotlin
precarga el sample con SoundPool, sin colas ni reproducción diferida, manteniendo
un solo stream y límite de 75 ms. Mutear tarjetas o llevar su volumen a cero
detiene solo home_slide; stop global del dock al salir/background sigue vigente.
La tabla de streams está acotada a uno; samples/ready/streams se liberan al
desconectar el plugin. No modifica AudioManager, volumen del dispositivo ni
focus/música. No se replica esta preferencia al engine overlay, que no presenta
Home ni usa estos sonidos. Sin nuevos timers/subscriptions ni caches de archivos.
Los dos unawaited son intencionales: navegación no espera audio y el adaptador
captura PlatformException/MissingPluginException.

Pruebas: persistencia/recreación, reset, mute/volumen cero, independencia de
menú/música, temas permitidos, errores de Hive/Android, asset/canal, gesto real
en Featured/Browse y controles accesibles en Audio. JSON y MP3 verificados,
git diff --check pasa. Pendiente gen-l10n, format/analyze/tests y compilación
Kotlin en CI: no hay SDK Flutter/Dart/Kotlin ni gradlew local. Prueba física:
primer swipe, swipes rápidos, volumen 0/100, desactivar/reabrir, background,
cambio de tema y coexistencia de música/menu. Motor Play/Workers intactos.

## Etiqueta Featured adaptable — Actions 40044057555

482 pruebas pasaron y dos variantes ES de Home fallaron por overflow horizontal
de 6,2 px en RetroTag, con ancho 320 y texto 1,6×. La nueva cobertura de Featured
hizo visible el problema preexistente. Su badge ahora activa flexibleLabel,
capacidad existente del componente, para permitir ajuste vertical sin reducir
accesibilidad ni modificar globalmente las etiquetas de otras pantallas.
La prueba de Home comprueba explícitamente esa configuración además del layout.
Audio y motor Play no cambian. git diff --check validado; Flutter pendiente en CI.

## Volúmenes iniciales suaves — 2026-10-23

Música ambiental y efectos del menú usan 0,05 (5 %) por defecto. Alineados el
modelo/proveedor Hive, fallbacks de valores ausentes/corruptos, adaptadores Dart,
valores defensivos nativos y Restablecer Deluxe. Los niveles ya guardados por
el usuario se conservan; el sonido de tarjetas Home mantiene su 45 % propio.
No se cambia el volumen Android ni se replica audio al overlay. Sin nuevos
caches, preferencias o Futures. Pruebas de defaults y música actualizadas;
git diff --check validado, Flutter/Kotlin pendientes en CI por falta de SDK.


## Idiomas y créditos — rama localization-fr-it-touch-authors

La app principal admite EN, ES/ES-419, PT/PT-BR, FR e IT. Los siete ARB
mantienen paridad de claves y argumentos ICU; inglés es la referencia. El
selector conserva en Hive las etiquetas antiguas y añade `fr`/`it`. Publica el
nuevo idioma solo después de guardar; una proyección fallida se revierte. En
arranque Hive reconcilia `app_locale` en SharedPreferences. Android lee esa
proyección sin caché mediante `AppLanguage.context`, sin alterar la configuración
global. Los Workers consultan el contexto al construir cada notificación y el
servicio cooperativo refresca la suya mediante un broadcast interno. Los nombres
de canales se actualizan preservando IDs y decisiones del usuario.

La burbuja queda explícitamente fuera de esta modificación por petición del
usuario: sigue el sistema y no recibe la selección de Ajustes. No se modifican
sus archivos ni su protocolo. Los recursos ARB nuevos están disponibles para
la resolución normal del sistema, sin sincronización adicional entre engines.

Touch Controls incorpora `author` opcional en JSON/modelo/entidad. Ausente,
nulo, vacío o inválido se presenta como `Release Soon`; los 27 registros
incluidos usan ese texto literal por petición del usuario. El catálogo fuente
se repara y coincide con assets. Tarjetas y Favoritos reutilizan la misma vista;
la identidad no depende del crédito. El catálogo remoto sigue pudiendo omitir
el campo. Su caché actual se invalida mediante el refresco existente.

Fechas y cifras de la app reciben el locale explícitamente, sin cambiar
`Intl.defaultLocale`. Los nombres de recursos, autores y contenido externo
conservan su idioma original. Los nombres de niveles de Partidas son etiquetas
descriptivas localizadas, conservando sus 24 posiciones e IDs del juego; no se
presentan como traducciones oficiales. La decoración japonesa de Retro Manga
se conserva. Errores de catálogos, instalación manual, favoritos y OTA ofrecen
explicaciones localizadas; los diagnósticos se pueden copiar.

No hay nuevas cachés persistentes ni Futures de IO añadidos sin await. El
servicio nativo conserva solo el último Intent de su notificación para
redibujarla al cambiar idioma; lo limpia y retira su receiver al destruirse. No cambian IDs de descargas,
Workers, archivos, destinos ni notificaciones. Validación de esta rama registrada
en PROJECT_STATUS; la revisión física de los cinco idiomas funcionales, texto
ampliado, cambio de idioma, notificaciones y reapertura sigue siendo necesaria.

## Atrás e historial de destinos principales — navigation-back-history

La navegación distingue destinos principales (Inicio, Catálogo, Popular,
Favoritos, Biblioteca, Jugador, Jugar, Partidas, Preparar ROM, Ajustes,
Cómo jugar, Recursos y colecciones) de pantallas secundarias. Las principales
usan `AppNavigator.openPrimary`, que registra la URI completa en
`MainNavigationHistory` y llama a `go`. Las secundarias usan `push`, incluidas
Permisos y accesos, el detalle de mod y una guía abierta desde una pantalla.

El historial vive solo en memoria, conserva query strings, identifica destinos
por `uri.path`, evita duplicados consecutivos y se limita a 20 entradas. Atrás
sigue este orden: cerrar drawer, diálogo, modal o submenú; hacer pop de una
secundaria; volver al destino principal anterior; volver a Inicio; y permitir
la salida únicamente desde Inicio sin historial.

`AppNavigator` es la única fuente del historial y del guard de Jugador. AppShell
lo expone mediante `AppNavigationScope`; drawer, dock Retro Manga, enlaces
internos y flecha visual comparten la misma política. El título visible no es
identidad. GoRouter sigue siendo autoridad de la ubicación activa y
`currentRouteProvider` es solo una proyección para resaltar el drawer; AppShell
la sincroniza al montar y al escuchar al router delegate.

`RetroPinnedAppBar` y `RetroFixedHeaderView` muestran hamburguesa en principales
clásicos, ningún leading en principales Manga/Deluxe y una flecha temática en
secundarias. La flecha reutiliza el material del botón de drawer y conserva
contraste, sombra, inclinación, tooltip y área táctil. Jugador mantiene
`PopScope`; el descarte sigue usando el mismo diálogo localizado, pero el
retroceso confirmado pasa por `AppNavigator` y ya no por `maybePop`.
