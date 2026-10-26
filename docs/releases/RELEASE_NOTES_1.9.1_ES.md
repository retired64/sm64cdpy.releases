## SM64CDPY v1.9.1 — Navegación más fluida y permisos guiados

La versión 1.9.1 es un parche de navegación: Atrás, los menús, el dock y la flecha visual comparten un único historial de destinos principales, y un nuevo centro Permisos y accesos con un recorrido guiado de cuatro pasos explica y solicita los accesos de Android solo cuando hacen falta.

### Atrás vuelve donde esperas

- Los destinos principales comparten un historial de 20 entradas como máximo, identificadas por la ruta, con duplicados consecutivos colapsados y query strings conservadas.
- El orden de Atrás es explícito: cerrar drawer, diálogo, modal o submenú; hacer pop de una secundaria; volver al destino principal anterior; volver a Inicio; y permitir la salida solo desde Inicio sin historial.
- El drawer clásico, el menú Retro Manga, el dock, los enlaces internos y la flecha temática usan la misma política, así que la misma acción se alcanza desde cualquier entrada.
- Los destinos principales conservan el botón de menú donde su tema lo espera y las pantallas secundarias muestran una flecha temática, incluida Permisos y accesos.
- Jugador mantiene el diálogo de cambios sin guardar; el descarte confirmado vuelve al destino anterior mediante la misma política y no por un pop separado.

### Permisos guiados

- Permisos y accesos es una pantalla secundaria dentro de Ajustes y muestra la carpeta del juego, notificaciones, acceso a todos los archivos cuando el dispositivo lo soporta, la burbuja flotante y la optimización de batería.
- Cada tarjeta indica permitido, no permitido u opcional, ofrece la acción Gestionar y bloquea solicitudes simultáneas; el estado se refresca al reanudar la app.
- Las notificaciones se solicitan en el momento de iniciar una operación en segundo plano; rechazarlas nunca bloquea la descarga ni la instalación.
- El recorrido guiado cubre bienvenida, selección de carpeta, instalación automática y comprobación final, con indicador de progreso y opción de posponerlo en el primer paso.
- Solo se persiste el progreso educativo, de modo que un permiso revocado desde Ajustes de Android aparece como no permitido la próxima vez que se abre la pantalla.

### Antes de publicar

- Este parche no obliga a actualizar y conserva el comportamiento de descarga, instalación, almacenamiento y overlay de 1.9.0.
- La fecha del manifiesto es provisional hasta la publicación.
- Falta validar físicamente Atrás desde cada destino, el drawer y los diálogos abiertos, los borradores de Jugador, la rotación y la reapertura.
- También falta validar conceder y revocar cada permiso, regresar de Ajustes de Android, la denegación de notificaciones en Android 13+ y una carpeta del juego revocada.
