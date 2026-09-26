# Estado y próximos pasos

Revisado contra `1.7.0+18` el 2026-09-24.

## Implementado

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
  Controls, OMM y Render96, con comparación conservadora de versiones.

## Experimental o pendiente de validación

- Biblioteca/historial: están implementados recibos, historial, proyección y
  verificación SAF; faltan la validación física con proveedores lentos, el
  selector en overlay y las superficies Biblioteca/Home.

- Overlay en Android 7–16, especialmente recreación del proceso y retorno desde permisos del sistema.
- Descargas simultáneas en dispositivo; las colisiones por títulos ya no son
  parte del identificador, pero falta validación física del paralelismo.
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
