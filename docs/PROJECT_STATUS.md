# Estado y próximos pasos

Revisado contra `1.7.0+18` el 2026-09-27.

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
  Controls, OMM, Render96 y overlay, con comparación conservadora de versiones.
- Biblioteca y Home con vistas instaladas/recientes, filtros, reconciliación
  SAF y navegación hacia el contenido de origen.
- Snapshot versionado de Biblioteca hacia el segundo engine del overlay, con
  descarte de respuestas antiguas y actualización tras instalación,
  verificación o cambio de carpeta.
- Detección conservadora de contenido Lua externo mediante SAF, con lectura
  limitada de encabezados, caché nativa separada, confianza estructural y vista
  Detectados sin fabricar identidad de catálogo ni recibos.
- Actualizaciones de Biblioteca contra artefactos canónicos del catálogo,
  clasificación durable de instalación/actualización/reinstalación, reemplazo
  lógico recuperable y mantenimiento individual sin borrar archivos del juego.
- Biblioteca alineada visualmente con Catálogo mediante pestañas y filtros
  inclinados, contadores, menús retro y estados vacíos coherentes. Los filtros
  gobiernan Actualizaciones y solo aparecen con opciones reales; las tarjetas
  evitan estados duplicados y detalles internos de detección.
- Modo oscuro con lienzo casi negro y superficies escalonadas inspiradas en
  GitHub Dark; conserva el acento cyan, usa bordes gris intermedio y reduce la
  trama de fondo para evitar una apariencia gris, deslumbrante o excesivamente
  luminosa.
- Navegación raíz unificada con barra superior compacta y fija: el botón del
  drawer permanece disponible durante scroll, carga y error. El drawer vuelve
  al inicio al abrirse, navega sin retraso artificial y ya no duplica los
  filtros y el ordenamiento propios del Catálogo.

## Experimental o pendiente de validación

- Biblioteca/historial: implementación funcional completada; falta ampliar la
  matriz física con proveedores SAF lentos, permisos revocados y texto grande.
- Sincronización de Biblioteca en overlay: implementada y cubierta por pruebas
  de codec/identidad/selector y por una matriz física de diez escenarios.
- Descubrimiento externo: fase 8 completada con pruebas automatizadas y matriz
  física aprobada en dispositivo real para contenido estructurado, Lua suelto,
  actualización manual, permisos/carpetas, exclusión de duplicados y protección
  frente a archivos parciales de una instalación activa.
- Actualización y mantenimiento de Biblioteca: fase 9 implementada y cubierta
  por pruebas automatizadas; pendiente matriz física de actualización,
  reinstalación, downgrade voluntario, reapertura y overlay.

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
