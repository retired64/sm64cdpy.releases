# Estado y próximos pasos

Revisado contra `1.7.0+18` el 2026-09-20.

## Implementado

- Catálogo principal y colecciones auxiliares desde JSON local/remoto.
- Búsqueda, filtros, orden, paginación, favoritos e importación/exportación.
- Localización EN/ES/PT y temas claro/oscuro.
- Selección de carpetas con SAF y lanzamiento del juego.
- Descarga/instalación WorkManager con progreso, cancelación y notificaciones.
- ZIP, 7z y archivos sueltos.
- Actualizaciones OTA por ABI.
- Overlay con búsqueda, órdenes de descarga y reflejo del progreso.

## Experimental o pendiente de validación

- Overlay en Android 7–16, especialmente recreación del proceso y retorno desde permisos del sistema.
- Descargas simultáneas de mods cuyos títulos sanitizados puedan coincidir.
- Restauración visual de trabajos activos después de reiniciar la app/engine.
- Proveedores SAF distintos (Files de Google, fabricantes y almacenamiento externo).
- URLs externas no cubiertas por la resolución especializada.

## Deuda priorizada para retomar el proyecto

1. Crear pruebas unitarias para sanitización, resolución de URL, modelos y selección de assets OTA.
2. Crear una prueba de integración del flujo UI → MethodChannel → WorkManager → EventChannel con dobles de plataforma.
3. Ejecutar una matriz manual Android 7, 10, 13, 14 y 16 con descarga, cancelación, segundo plano y pérdida de permiso.
4. Verificar en dispositivo dos descargas paralelas y colisiones de nombres e IDs de notificación.
5. Revisar la restauración de `_infoMap` desde WorkManager tras process death.
6. Añadir una comprobación CI ligera para pull requests cuando el repositorio vuelva a tener una estrategia de ramas estable.

## Fuera del estado vigente

`floating-check-list.md`, `revision-app.md` y `.opencode/plans/` son fotografías de análisis anteriores a/durante 1.7.0. Contienen puntos ya resueltos y otros no revalidados; no deben usarse como backlog sin contrastarlos con el código. El inventario completo está en [archive/README.md](archive/README.md).
