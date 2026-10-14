## SM64CDPY v1.8.3 — Control de mods y la interfaz Mario 64

La versión 1.8.3 incorpora activación verificada de mods desde Biblioteca, reúne la información de los mods locales y añade la interfaz Mario 64 junto a Retro Manga con selectores coherentes en Ajustes.

### Biblioteca y control de mods del juego

- Mods del juego es la vista principal de Biblioteca. Sustituye la pestaña Detectados y muestra tanto mods existentes como contenido instalado por SM64CDPY cuando cumplen la estructura compatible con el juego.
- La activación usa el nombre real de la carpeta o archivo Lua. Búsqueda local, filtros de activados/desactivados, contadores y detalles de solo lectura incluyen autor, categoría, versión informativa y descripción cuando existen.
- Selecciona una vez la carpeta user del juego para conceder acceso persistente a sm64config.txt. Cierra el juego antes de editar: la selección se aplica en el próximo inicio, y DynOS/Touch Controls mantienen su configuración independiente.
- El guardado comprueba incompatibilidades locales conocidas y el límite de tamaño del juego, conserva las demás líneas de configuración, crea un respaldo privado y verifica el resultado escrito. La configuración anterior puede restaurarse con confirmación.
- Tarjetas, controles, progreso, diálogos y avisos de guardado siguen el tema elegido. La vista retirada ya no provoca otro escaneo automático; recibos de instalación, comprobación de actualizaciones e historial conservan sus funciones propias.
- Una sola carpeta user del juego conecta Biblioteca, mods, DynOS/Touch Controls y detección de ROM para temas Mario. La guía explica el selector; los temas preparados reutilizan sus recursos privados.

### Temas Retro Manga y Mario 64

- Retro Manga sigue como tema por defecto. Mario 64 reconstruye la interfaz principal con materiales del selector original, marcos cuadrados, cielos del juego y HUD en modos claro y oscuro.
- Los temas se recuerdan al reabrir. Elegir Mario 64 pide la ROM una vez si falta su conjunto local completo; cancelar conserva el tema anterior. El brillo sigue siendo independiente.
- Mario 64 utiliza fuentes de menú, diálogo y HUD generadas privadamente desde la ROM. Los encabezados a color usan glifos originales; caracteres ausentes de la ROM US conservan un fallback legible para el idioma.
- Una ROM US .z64 sin modificar proporciona 151 imágenes y tres fuentes generadas, incluidos materiales, cursores, iconos y cielos Clouds/BBH. Los recursos quedan privados y fuera del backup Android; no se incluye ROM ni arte extraído en el APK. Las importaciones antiguas de 15 texturas pueden actualizarse sin perderlas al cancelar.
- SM64 Intro añade un menú dorado de día y azul nocturno, con paneles oscuros, letras de la ROM y controles de ranura Mario para mods activos/inactivos confirmados. Reutiliza la importación de ROM de Mario 64.
- La ficha del mod usa portada enmarcada sin banner, paneles de menú legibles, estadísticas adaptables y textos mayores. Las etiquetas de descarga y fechas se distribuyen sin recortarse.

### Ajustes coherentes

- Tema de interfaz, modo de apariencia e idioma muestran la selección actual y despliegan sus opciones con el mismo diseño.
- El selector de idioma conserva las animaciones de flecha y expansión, y se cierra después de guardar la selección.
- Mario 64 incorpora superficies de menú, marcos biselados e indicadores de selección coherentes en Ajustes.
- Los encabezados de Mario 64 aprovechan el ancho disponible; Ajustes distingue tamaños legibles para opciones, descripciones y rutas.

### Recuperación de apariencia y legibilidad

- Los cambios de apariencia se confirman después de guardar; se bloquean solicitudes simultáneas y los fallos conservan la selección anterior.
- Las instalaciones anteriores conservan su modo de apariencia. Los IDs de diseño ausentes o no disponibles recuperan Retro Manga.
- Botones rellenos, etiquetas, filtros y superficies de progreso usan el color de texto correspondiente a su contraste.

### Panel flotante y actualizaciones

- El panel flotante conserva su diseño oscuro fijo e independiente. La selección de tema y la edición de mods se aplican a la app principal.
- Se mantiene el funcionamiento de descargas e instalaciones. La versión 1.8.3 es una actualización opcional.
