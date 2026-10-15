## SM64CDPY v1.8.4 — Una Biblioteca más rápida y fluida

La versión 1.8.4 agiliza la carga de Biblioteca y hace que los controles de mods respondan al instante mientras Android confirma los cambios de configuración.

### Una Biblioteca más fluida

- Abrir Mods del juego o DynOS ya no inicia en segundo plano la revisión de recibos ni la carga del catálogo de actualizaciones.
- Al volver a esas secciones se reutiliza el snapshot reciente. La lista permanece visible durante la actualización; cambiar la carpeta y terminar una instalación invalidan los datos; reanudar la app con la sección abierta o actualizar manualmente solicita datos actuales.
- Los contadores aparecen conforme cada sección obtiene sus datos, sin retrasar la vista activa para mostrar información que todavía no necesita.

### Respuesta más rápida al activar

- Después de confirmar, el mod Lua o pack DynOS cambia en pantalla enseguida mientras Android guarda la configuración del juego.
- Un indicador muestra que el guardado sigue pendiente hasta que Android verifica exactamente el archivo escrito. Si falla, el control vuelve al último estado confirmado.
- El gestor valida el elemento seleccionado y los metadatos Lua activos necesarios, sin reconstruir toda la lista después de cada cambio. Se mantienen la comprobación de tamaño Lua, la copia de configuración, el control de conflictos y la protección durante instalaciones.
- El juego aplica los cambios en el siguiente inicio. La velocidad del proveedor SAF y las carpetas grandes todavía pueden afectar la confirmación de una escritura real.
