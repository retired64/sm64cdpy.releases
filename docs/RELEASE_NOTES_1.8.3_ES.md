<!-- Generated preview from release-manifests/v1.8.3.json; edit that manifest, not this file. -->

## SM64CDPY v1.8.3 — Control de mods y la interfaz Mario 64

La versión 1.8.3 incorpora activación verificada de mods desde Biblioteca, reúne la información de los mods locales y añade la interfaz Mario 64 junto a Retro Manga con selectores coherentes en Ajustes.

### Biblioteca y control de mods del juego

- Mods del juego es la vista principal de Biblioteca. Sustituye la pestaña Detectados y muestra tanto mods existentes como contenido instalado por SM64CDPY cuando cumplen la estructura compatible con el juego.
- La activación usa el nombre real de la carpeta o archivo Lua. Búsqueda local, filtros de activados/desactivados, contadores y detalles de solo lectura incluyen autor, categoría, versión informativa y descripción cuando existen.
- Selecciona una vez la carpeta user del juego para conceder acceso persistente a sm64config.txt. Cierra el juego antes de editar: la selección se aplica en el próximo inicio, y DynOS/Touch Controls mantienen su configuración independiente.
- El guardado comprueba incompatibilidades locales conocidas y el límite de tamaño del juego, conserva las demás líneas de configuración, crea un respaldo privado y verifica el resultado escrito. La configuración anterior puede restaurarse con confirmación.
- Tarjetas, controles, progreso, diálogos y avisos de guardado siguen el tema elegido. La vista retirada ya no provoca otro escaneo automático; recibos de instalación, comprobación de actualizaciones e historial conservan sus funciones propias.

### Temas Retro Manga y Mario 64

- Retro Manga sigue siendo el tema predeterminado. Mario 64 incorpora paletas clara y oscura, superficies con relieve, fondos inspirados en cielos y detalles de estrellas en la app principal.
- Los temas vienen incluidos sin conexión, se recuerdan al volver a abrir y se eligen de forma independiente del modo claro, oscuro o del sistema.
- Mario 64 utiliza TypefaceMario64 en títulos y encabezados grandes, incluidos los nombres de mods de Top downloads en Home. Las descripciones conservan la fuente predeterminada y Roboto cubre los caracteres acentuados ausentes en la fuente de títulos.
- Mario 64 permite importar piedra del menú, cursores, estrellas y dígitos del HUD desde una ROM estadounidense sin modificar elegida por el usuario. Los recursos permanecen privados en el dispositivo; fallos o cancelación conservan el diseño anterior. No se incluye una ROM ni imágenes extraídas.

### Ajustes coherentes

- Tema de interfaz, modo de apariencia e idioma muestran la selección actual y despliegan sus opciones con el mismo diseño.
- El selector de idioma conserva las animaciones de flecha y expansión, y se cierra después de guardar la selección.
- Mario 64 incorpora superficies de menú, marcos biselados e indicadores de selección coherentes en Ajustes.

### Recuperación de apariencia y legibilidad

- Los cambios de apariencia se confirman después de guardar; se bloquean solicitudes simultáneas y los fallos conservan la selección anterior.
- Las instalaciones anteriores conservan su modo de apariencia. Los IDs de diseño ausentes o no disponibles recuperan Retro Manga.
- Botones rellenos, etiquetas, filtros y superficies de progreso usan el color de texto correspondiente a su contraste.

### Panel flotante y actualizaciones

- El panel flotante conserva su diseño oscuro fijo e independiente. La selección de tema y la edición de mods se aplican a la app principal.
- Se mantiene el funcionamiento de descargas e instalaciones. La versión 1.8.3 es una actualización opcional.
