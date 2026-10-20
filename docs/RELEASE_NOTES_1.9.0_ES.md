## SM64CDPY v1.9.0 — Prepara tu ROM y un Retro Manga más consistente

La versión 1.9.0 añade un preparador local de ROM para el juego de Android y completa el sistema visual de papel y tinta de Retro Manga en tarjetas, diálogos, campos, menús y controles secundarios, manteniendo aislados los demás temas.

### Preparación local de ROM

- Abre el preparador desde el capítulo 2 de Cómo jugar o desde GameTool. Ambos accesos comparten servicio, provider y estado de operación.
- Elige tu propio archivo .z64, .v64 o .n64. La herramienta detecta el formato por cabecera, lo normaliza si hace falta y valida el volcado USA de 8 MiB y su MD5.
- La conversión se ejecuta de forma nativa por bloques con un staging aislado. El original permanece en solo lectura y ningún byte de la ROM cruza a Flutter.
- La exportación usa el selector de documentos de Android y después reabre la copia para verificar tamaño y hash antes de confirmar el éxito. No se necesita el permiso general de administrar todos los archivos.
- Hay progreso real por fase, cancelación, reintento y errores accionables. La copia privada preparada y la copia externa verificada se muestran como estados distintos.

### Consistencia de Retro Manga

- Las tarjetas y paneles neutros completan automáticamente su borde de tinta y sombra dura, incluidos el preparador de ROM, Save Files, los grupos de Ajustes y las filas activas del drawer.
- Diálogos, campos de texto, menús, chips, botones estándar, switches, checkboxes, sliders, barras de progreso, pestañas, ExpansionTile y tooltips comparten ahora la misma geometría rectangular de papel y tinta.
- Save Files, Cómo jugar, el detalle de mods, Jugador y el diálogo posterior a la instalación ya no anulan el tema compartido con bordes o controles redondeados locales.
- Los encabezados de sección conservan su identidad manga inclinada, aplican las mayúsculas del tema y truncan los títulos largos solo cuando falta espacio.
- Minimalista, Minish Cap, Mario Kart 64, Mario 64 y SM64 Intro conservan sus propios tratamientos. La burbuja flotante tampoco cambia.

### Optimizaciones menores

- Una única política de decoración compartida sustituye condiciones repetidas por pantalla y evita overrides locales redundantes.
- No se introducen blur, shaders, animaciones ni recursos raster nuevos. El fondo de semitono permanece aislado en su RepaintBoundary.
- Las transiciones de tema mantienen estilos de texto compatibles y las pruebas cubren layouts de 320/360 px con texto español ampliado.

### Límites conocidos

- El preparador acepta el volcado USA original de Super Mario 64 para el juego de Android. No cambia regiones, aplica parches, repara dumps ni lee archivos ZIP/7z.
- Este release exporta una copia verificada; no reemplaza la ROM que ya usa el juego. Cierra el juego antes de mover la copia manualmente.
- Sigue pendiente la validación física con proveedores SAF locales, remotos y lentos, rotación, poco espacio, cancelación y un volcado real de cartucho.

### Primeros pasos

- La guía Cómo jugar explica el juego de Android, tu propia ROM, las carpetas y el primer mod. Al abrir sin el juego instalado se ofrece la guía.
- Puedes volver al preparador desde GameTool sin recorrer de nuevo toda la guía.
