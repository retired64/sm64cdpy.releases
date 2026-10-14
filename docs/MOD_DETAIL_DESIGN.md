# Ficha de mod: reconstrucción del menú y legibilidad

Se inspeccionaron las dos capturas de `/sdcard/Pictures/Screenshots/` del
14 octubre 2026. Mostraban una franja dorada con degradado detrás de una miniatura,
navegación sobre la portada, título HUD de 25 puntos desproporcionado, cuatro
estadísticas comprimidas, fechas truncadas y botones de menú demasiado anchos.
Los datos de texto de 10–14 puntos tenían menor legibilidad con las fuentes ROM.

## Estructura y tipografía

- Navegación fija sobre una superficie del tema; no se superpone a la imagen.
  Los iconos de las barras Android derivan de la luminancia del fondo real: el
  marrón del modo claro de SM64 Intro necesita iconos claros, igual que el azul
  nocturno. No se infiere ese contraste solo del nombre claro/oscuro.
- Una sola ficha de cabecera enmarca la portada a 112×112 sin recortarla, conserva
  el Hero existente y muestra placeholder si falta imagen o falla su carga.
- En teléfonos: portada, título completo, autor, versión y categoría en una
  columna. Con 420 puntos útiles y texto normal se usa disposición lateral.
  Texto ampliado vuelve a la columna. Se conserva la insignia de destacado.
- Se elimina el banner, el degradado de costura y el desplazamiento negativo.
  No hay portada que desaparezca al desplazar ni listeners que reconstruyan
  toda la pantalla por cada píxel de scroll. La animación de entrada continúa.
- Título Mario de 19 puntos; Retro Manga de 22. Texto completo sin elipsis.
- Estadísticas: dos columnas en teléfono, cuatro desde 560 puntos útiles si
  la escala de texto lo permite. Los nombres pueden ocupar varias líneas.
- Paneles independientes para descargas, descripción, capturas, etiquetas y
  cambios; fechas y estadísticas mantienen sus superficies de contraste.
- En Mario: captions de 16 puntos, valores de 17 y descripción de 18 con Roboto
  y altura 1.5. Las fuentes originales se reservan para títulos, controles y
  texto corto; la descripción usa una fuente diseñada para lectura extensa.
- El helper de texto de Mario tiene mínimo 16 (antes 14), compartido con
  Ajustes y Biblioteca. El estilo común de botones usa diálogo de 16 para
  textos extensos; menú/HUD permanece en encabezados. Retro conserva su escala.
- Botón principal crece con el texto; etiquetas largas y progreso no se
  desbordan de una fila rígida. Fechas, descargas y valoración de cada versión
  se distribuyen con Wrap para evitar cortar la fecha por falta de ancho.

## Comportamiento preservado

No se cambia la fuente de verdad de instalación, identidad, URL resolver,
selección de variantes, detección de versión, auto-install, cancelación,
reinstalación ni proyección WorkManager. Los botones conservan callbacks y
estados de `installationActionProvider`. Favoritos, autor, discusión, enlaces,
versiones anteriores, galería, fechas y changelog siguen accesibles. No se añade
un segundo coordinador de resultados ni snackbar de éxito visual.

La ficha general comparte estas superficies con Retro Manga, Mario 64 y SM64
Intro. DynOS, VIP, Render96 y OMM conservan sus flujos propios; el helper de
legibilidad/controles se propaga mediante ThemeData. El overlay usa su extensión
fija y no recibe el nuevo mínimo de Mario. Los recursos ROM no se reimportan ni
cambia su caché, versión o persistencia. Las fotos permanecen fuera del repo.

## Validación

Prueba de regresión de pantalla estrecha con título largo, texto al 150 % y
los tres temas: cabecera debajo de navegación, portada acotada y scroll sin
excepciones de layout. Se mantienen las pruebas de contraste, identidad y
acciones de instalación. Flutter/Dart no están instalados en Termux; formato,
análisis, generación l10n si procede y tests se ejecutan en Actions. Pendiente
prueba física: claro/oscuro, todas las versiones, imagen ausente/fallida,
expandir descripción, galería, favoritos y transferencia desde la ficha.
