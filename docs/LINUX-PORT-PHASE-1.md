# Linux Port — Fase 1: shell y catálogo de solo lectura

> Resultado técnico de la primera integración ejecutable para Linux, sin
> prometer descargas o instalaciones antes de disponer del backend filesystem.

| Campo | Resultado |
|---|---|
| Fecha | 2026-09-28 |
| Rama | `linux-port` |
| Estado | Implementada; recorrido físico pendiente |
| Alcance | Catálogo, favoritos, navegación, detalle y ajustes seguros |
| Instalación Linux | Deshabilitada de forma explícita |

## Resultado

Linux inicia únicamente persistencia y versión comunes. No inicializa el
downloader móvil, OTA de APK, EventChannel, MethodChannel de Biblioteca,
proyección nativa ni bridge del overlay. Android conserva el orden y las
implementaciones que ya utilizaba.

La selección de plataforma vive en un único punto de composición y se proyecta
como capacidades inmutables. Las pantallas no contienen comprobaciones
dispersas de `Platform.isLinux`.

## Flujo Linux de Fase 1

```text
arranque
  → versión + Hive
  → catálogo compartido
  → providers sin canales Android
  → Biblioteca vacía de solo lectura
  → navegación y favoritos disponibles
  → descarga solicitada
      → aviso localizado de función todavía no disponible
```

El repositorio temporal de Biblioteca siempre devuelve un snapshot vacío. No
lee la proyección Hive de Android ni la presenta como evidencia de archivos
Linux. Sus mutaciones son no-op seguras hasta que las fases de localizador,
backend y recibos definan autoridades reales.

## Experiencia visible

- Home, Catálogo y todas las colecciones continúan usando sus bases compartidas.
- Favoritos, tema e idioma permanecen disponibles mediante Hive/preferencias.
- El botón de abrir el juego no aparece mientras Linux no tenga un lanzador
  aprobado.
- Ajustes SAF, auto-install, burbuja y OTA APK no aparecen en Linux.
- Ajustes muestra el estado `LINUX · READ ONLY` y explica el alcance actual.
- Los botones de transferencia conservan contexto visual, pero al pulsarlos
  muestran una explicación localizada; nunca invocan plugins Android.
- La ventana inicia a 480 × 820, puede redimensionarse y tiene mínimo 360 × 600.

## Validación automatizada

| Puerta | Resultado |
|---|---|
| `flutter gen-l10n` | Correcto |
| `flutter analyze lib` | Sin incidencias |
| `flutter test` | 50 pruebas aprobadas |
| `flutter build linux --debug` | Correcto |
| Ejecución del bundle Linux durante 20 s | Sin `MissingPluginException` ni errores Dart continuos |
| `flutter build apk --debug` | Correcto |
| `git diff --check` | Correcto |

La ejecución GTK conserva una advertencia ATK del entorno automatizado. No
provino de Flutter, de los plugins ni del flujo de SM64CDPY y no bloqueó el
primer frame.

## Recorrido físico pendiente

Antes de comenzar la Fase 2 se recomienda comprobar en Linux:

1. abrir Home, Catálogo, Favoritos y una ficha de mod;
2. navegar por VIP, DynOS, Touch Controls, OMM y Render96;
3. añadir y retirar un favorito, cerrar y reabrir la aplicación;
4. usar mouse, rueda, drawer, botones Atrás y teclado básico;
5. pulsar una descarga en cada tipo de destino y confirmar el aviso localizado;
6. abrir Ajustes y confirmar que no aparecen SAF, burbuja ni actualización APK;
7. recargar la base remota y confirmar éxito o un error recuperable;
8. redimensionar hasta el mínimo y maximizar sin overflow visible;
9. comprobar que la consola no emite `MissingPluginException`.

## Límites intencionales

Esta fase no localiza SM64CoopDX, no elige rutas XDG, no descarga archivos y no
detecta instalaciones. Implementar cualquiera de esas acciones aquí habría
creado una segunda fuente de verdad antes de los contratos de las fases 2–3.

## Verificación de sincronización de estado

- **Quién escribe y lee:** Hive sigue escribiendo/leyendo tema, idioma y
  favoritos. Android continúa escribiendo operaciones, recibos y proyección
  mediante WorkManager, Kotlin y sus servicios Flutter. Linux solo lee el
  catálogo y produce una Biblioteca vacía temporal.
- **Fuente de verdad:** WorkManager/SAF permanecen como autoridad Android. En
  Linux todavía no existe autoridad de instalación; el snapshot vacío evita
  fingir una.
- **Sincronización:** el provider de capacidades gobierna bootstrap, estado de
  operaciones, Biblioteca, Ajustes y acciones de transferencia. No se abrió
  ningún canal nativo Android durante la ejecución Linux.
- **Caches:** no se añadió cache de instalación. Hive mantiene los caches ya
  existentes; el repositorio Linux deliberadamente no reutiliza la proyección
  Android.
- **Futures no esperados:** no se introdujeron nuevos Futures productivos sin
  `await`. Los refrescos existentes de providers conservan su manejo previo.
- **Hermanos revisados:** detalle general, VIP, DynOS, Touch Controls, OMM,
  Render96, Home, Biblioteca, Ajustes, coordinador global y overlay Android.
