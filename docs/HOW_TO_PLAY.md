# Guía de inicio — How to Play / Cómo jugar / Como jogar

Rama `how-to-play-guide`, creada desde `main` (8866418). No cambia versión,
no publica releases ni fusiona a main.

## Experiencia

Recursos del drawer abre `/how-to-play`. Seis pasos consultables libremente:
instalar el port Android, preparar ROM, entregarla al juego, conectar la carpeta,
instalar/activar un mod y jugar/resolver problemas. Conversión y mapa de rutas
son ayudas desplegables. No se exige completar casillas ni se confunde avanzar
con instalación correcta. Lenguaje sencillo y numerado; APK, ROM y manager se
explican por separado. No se distribuyen ROMs ni se enlaza a descargas de ROMs.

La pantalla comparte `RetroPinnedAppBar`, `surfaceDecoration`,
`GameSetupAction`, `GameSetupStatus` y tipografías de cada tema. Las opciones
se ajustan al ancho; no hay dimensiones de texto ni paneles de altura fija.
Todo el contenido está en los cinco ARB, con inglés, español y portugués BR.
La lectura es local y funciona sin internet; descargar APK/conversión abre el
navegador externo y ofrece un error recuperable si no puede abrirse.

## Flujo y fuentes

- `game_launch_flow.dart`: Home, guía y diálogo posterior a instalación
  comparten lanzamiento. Si falla, consulta instalación de nuevo: juego ausente
  ofrece guía/Ahora no; juego presente informa que no pudo abrirse, sin afirmar
  que falta. Cerrar el popup nunca navega. No instala APK automáticamente.
- `HowToPlayScreen`: reconsulta instalación y `GameFolderNotifier.refresh()`
  al iniciar y reanudar; ignora respuestas antiguas con revisión/mounted. Retira
  observer y ScrollController en dispose. No persiste avance ni crea caches.
- Android PackageManager, a través de `GameLauncherService`, determina juego
  instalado. `gameInstalledProvider` es una proyección de presentación existente.
- `GameFolderStore`/permisos SAF siguen siendo autoridad de conexión. La guía
  reutiliza `connectGameFolder`, con explicación previa al selector. No escribe
  URI, mods, ROM o configuración directamente. El provider conserva las
  invalidaciones de Biblioteca/Jugador y el bridge del overlay existentes.
- Futures de lifecycle usan `unawaited(_refresh())` con errores capturados;
  acciones se esperan con guard busy y finally. No hay éxito inventado.
- El diálogo postinstalación devuelve intención de lanzamiento antes de abrir
  otro diálogo y ofrece guía cuando falta el juego; ya no dispara un Future de lanzamiento sin esperar su resultado.

## Contratos contrastados

Fuentes oficiales consultadas el 2026-10-19:

- [Port Android y releases](https://github.com/ManIsCat2/sm64coopdx/releases).
  La nota Av1.5 introdujo selector de ROM. Se enlaza al listado sin fijar APK o
  versión, y se indica consultar requisitos de cada release.
- [rom_checker.cpp, rama android](https://github.com/ManIsCat2/sm64coopdx/blob/android/src/pc/rom_checker.cpp):
  valida MD5 USA `20b854b239203baf6c961b850a4a51a2`, escanea `.z64`, conserva
  `baserom.us.z64`. Formato cambiado no convierte región ni deshace un ROM hack.
- [platform.c](https://github.com/ManIsCat2/sm64coopdx/blob/android/src/pc/platform.c):
  la carpeta depende de permisos del juego. La guía presenta la ruta compartida
  habitual, explica la variación y no promete acceso a Android/data.
- Resolver real de esta app: `GameFolderLayout.kt`, `GameFolderStore.kt`,
  `GameModActivationStore.kt` y [UNIFIED_GAME_FOLDER.md](UNIFIED_GAME_FOLDER.md).
  Raíz elegida `com.maniscat2.sm64coopdx`, escritura nueva en `user/mods` y
  `user/dynos/packs`; lectura de ambas ramas con precedencia diferente.
- [Conversor externo Hack64](https://hack64.net/tools/swapper.php): enlace de
  ayuda para conversión de orden de bytes, sin subir ROM desde el manager.
  Su servidor no respondió durante la comprobación en Termux; no se garantiza
  disponibilidad. La guía explica salida .z64 y alternativa de otro conversor.
  Cambiar únicamente la extensión NO convierte.

No se implementa otro importador de ROM, instalador de APK ni sistema de rutas.

## Validación

Pruebas de widget: guía en seis temas, claro/oscuro y tres idiomas, ancho 360
con escala 1.3, navegación por los seis pasos; popup ausente permite cancelar y
abrir guía sin navegar automáticamente. Flutter gen-l10n debe producir los
Dart generados; no se editan manualmente.

Pendiente revisión física: primera instalación desde navegador, permisos de la
versión del juego, selector de ROM, carpeta existente/ausente/revocada,
volver desde navegador/Ajustes, texto grande y conversor externo disponible.
No se afirma validación funcional en dispositivo sin ejecutar estos escenarios.

Validación remota de la candidata `29a3d31`:
[Testing](https://github.com/retired64/sm64cdpy.releases/actions/runs/39337289411)
generó traducciones, aplicó formato y pasó análisis sin errores nuevos y las
250 pruebas Flutter. Los generados/formato se sincronizan desde su artifact,
sin modificar archivos ajenos a esta tarea. APK arm64 en compilación al registrar
esta evidencia; validación física pendiente. Validación local: cinco ARB JSON
con 38 claves coherentes, cuatro pruebas Python del manifiesto y diff-check.
