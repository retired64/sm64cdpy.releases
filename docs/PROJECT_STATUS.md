# Estado y próximos pasos

Revisado para la preparación de `1.8.3+22` en `custom-themes` el 2026-10-14; sin merge ni publicación.

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
- Vista única Mods del juego para unidades Lua válidas, propias o externas,
  con activación verificada y metadata limitada de autor/categoría/versión/descripcion.
  Detectados fue retirada; no se inventan recibos ni identidades de catálogo.
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
- Contrato de catálogo v2 con identidades estables de versión/archivo,
  compatibilidad temporal con recibos posicionales de 1.8.0 y aprovechamiento
  de metadata de resolución/procedencia del scraper.
- Actualización remota transaccional: validación integral previa, control de
  esquema y conteo, barrera contra reducciones anómalas, reemplazo atómico,
  copia `last-good`, cuarentena y fallback a la base incluida en el APK.
- Resolución en tiempo de descarga para páginas estables de MediaFire,
  GameBanana y archivos de Google Drive; las carpetas Drive no resolubles se
  presentan como enlace de origen sin afirmar que fueron instaladas.

## Temas incluidos en custom-themes (2026-10-13)

- Menú de diseños propios y menú de modo de brillo independientes, ambos expandibles en Ajustes.
- Dos definiciones incluidas (Retro Manga y Mario 64); contraste, radios, bordes, sombras y decoración
  adaptados en las pantallas y widgets de la app.
- Persistencia confirmada y recuperación legacy; overlay mantiene diseño fijo.
- ARB y pruebas preparados; generación, análisis, tests y APK pendientes en
  Actions porque el entorno Termux de esta tarea no tiene Flutter/Dart.
- Guía/inventario completos: [cuatom_themea.md](../cuatom_themea.md).

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

## Posterior a 1.8.0

La desinstalación física queda planificada para `1.9.0` en tres fases:
manifiesto completo de propiedad, Worker SAF conservador y sincronización de la
experiencia entre Biblioteca, catálogo y overlay. El plan está en
[SAFE-UNINSTALL-v1.9.0-ROADMAP.md](SAFE-UNINSTALL-v1.9.0-ROADMAP.md). Los
centinelas actuales verifican presencia, pero no se usarán como autorización
para borrar archivos.

## Fuera del estado vigente

`floating-check-list.md`, `revision-app.md` y `.opencode/plans/` son fotografías de análisis anteriores a/durante 1.7.0. Contienen puntos ya resueltos y otros no revalidados; no deben usarse como backlog sin contrastarlos con el código. El inventario completo está en [archive/README.md](archive/README.md).

### Ajustes visuales posteriores a la prueba aprobada

Selector de idioma alineado con los dos selectores de apariencia, manteniendo
animaciones. Mario 64 usa paneles discretos, iconos/toggles redondeados y
cabeceras limpias en Ajustes. Código y pruebas añadidos; nueva Actions y matriz
física de idioma/tamaño de texto pendientes.

## Preparación oficial 1.8.3+22

- Notas finales EN/ES/PT-BR incluyen Biblioteca unificada, edición de mods,
  Retro/Mario, ajustes y fuente de títulos; previews generadas para revisión.
- Testing #183–#186 terminó correctamente; #187 pasó análisis/78 tests Flutter.
- Generación/formato de #187 incorporados solo en archivos del alcance.
- Merge simulado contra main remoto `8bdc996` sin conflictos, sin fusionar.
- Testing admite todas las ABI por input manual o `[testing] [all-abis]`.
- Pendientes: ejecución consolidada, matriz física/ABIs, fecha final y
  autorizaciones de merge/publicación. [Checklist](RELEASE_1.8.3.md).

## Activación de mods — candidata 1.8.3

Biblioteca incluye una sección de unidades Lua del juego con switches de selección
para el próximo inicio. SAF autoriza `user`; el servicio nativo conserva ajustes,
comprueba identidades/incompatibilidades/tamaño, crea respaldo y verifica la escritura.
DynOS/Touch mantienen su contrato separado. La validación física está pendiente.
Plan, archivos, estados y matriz: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md).
Ambos workflows ejecutan también `:app:testReleaseUnitTest`. No hay merge ni release.

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

## SM64 Intro

Nuevo diseño `sm64_intro` con ambiente dorado en claro y azul nocturno en oscuro,
paneles de menú y ranuras Mario activas/inactivas. Comparte el conjunto ROM v2
con Mario 64, sin reimportación si ya está preparado. Plan, inventario de
integración y validación: `docs/SM64_INTRO_THEME.md`. Testing pendiente.

Validación: [Testing #206](https://github.com/retired64/sm64cdpy.releases/actions/runs/38636988190) completado correctamente: generación l10n, formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas. Los commits posteriores solo sincronizan formato probado y documentación. Pendiente prueba visual física de SM64 Intro.

## Ficha de mod y lectura

Portada sin banner, navegación sin solapamientos, paneles y estadísticas
adaptables. Mario eleva texto mínimo a 16 y descripción a 18 puntos.
Plan técnico: `docs/MOD_DETAIL_DESIGN.md`. Testing pendiente.

Validado en [Testing #213](https://github.com/retired64/sm64cdpy.releases/actions/runs/38641643668): formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas completados correctamente. Los commits posteriores sincronizan formato probado y documentación. Pendiente revisión visual física de la ficha en claro/oscuro.

## Conexión unificada del juego

Rama `unified-game-folder` basada en `custom-themes`: user como raíz autorizada,
mods y dynos/packs derivados y ROM detectada sin otra selección. Contrato,
migración, resolver de documentos SAF y matriz: [UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md).
Validado en [Testing #225](https://github.com/retired64/sm64cdpy.releases/actions/runs/38658236343): generación l10n, formato, análisis, pruebas Flutter, APK arm64 y pruebas nativas correctos para `458189b`. La sincronización posterior solo incorpora formato del runner. Revisión física de permisos, rutas y ROM requerida.

Conexión guiada: superficies y acciones propias de cada tema, desplegable de
Ajustes coherente con selectores y estados separados de configuración/ROM.
Pruebas de interfaz y testing de esta revisión pendientes. Detalle en
[UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md).
