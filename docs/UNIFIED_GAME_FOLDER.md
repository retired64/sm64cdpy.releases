# Una conexión a la carpeta user — unified-game-folder

Rama creada desde `custom-themes`. La única selección habitual es la carpeta
`user` de la instalación elegida por el usuario, normalmente bajo
`com.maniscat2.sm64coopdx`. No se asume acceso por conocer una ruta en /sdcard.
No cambia la versión oficial 1.8.3+22 ni se fusiona/publica main.

## Contrato con SM64CoopDX

- `src/pc/platform.c::sys_user_path`: `<get_gamedir()>/user` en Android.
- `src/pc/mods/mods.c`: escanea `fs_get_write_path("mods")` y también mods locales
  del juego. El manager gestiona la parte autorizada `user/mods`, no recursos
  internos del APK del juego.
- `data/dynos.h`: `DYNOS_RES_FOLDER="dynos"`, `DYNOS_PACKS_FOLDER="dynos/packs"`.
  `DynOS_Gfx_Init` escanea packs de usuario y de recursos del juego.
- `src/pc/rom_checker.cpp`: valida ROM US por MD5 y conserva una copia en
  `user/baserom.us.z64`; escanea `.z64` directamente en la carpeta de usuario.
- `sm64config.txt` controla activación Lua mediante el contrato existente. No
  se crean ni reescriben configs vacías para simular un juego preparado.

La conexión crea únicamente las carpetas de destino conocidas que falten:
mods, dynos y dynos/packs, dentro de un `user` reconocible. Rechaza archivos que
ocupen esos nombres y carpetas ajenas. No mueve, elimina ni reemplaza contenido.
La falta de configuración bloquea editar activación, no descargas/temas.

## Autoridad y URI

`GameFolderStore` es autoridad nativa. `game_user_tree_uri` identifica la raíz
con permiso persistido de lectura/escritura. `tree_uri` y `dynos_tree_uri` son
proyecciones derivadas, confirmadas juntas por un único commit de preferencias.
Se preservan los nombres para compatibilidad con los flujos existentes.

Los destinos contienen URI de documento con el árbol original de user. Es
incorrecto llamar solo `DocumentFile.fromTreeUri` a esas URI: devuelve la raíz
del árbol, no el destino. `GameFolderAccess` comprueba el permiso del árbol y
`GameFolderLayout` resuelve los hijos por nombres del juego e IDs reales,
incluso si el proveedor utiliza IDs opacos. Un hijo no encontrado nunca retorna
user como alternativa. Worker, instalación directa, SAF verifier y scanner
usan el mismo resolver. `SafZipExtractor` sigue siendo la implementación única
de escritura/extracción y sus journals/recibos no se duplican.

Cada Worker conserva la URI capturada al encolar. No consulta la carpeta nueva
para redirigir una operación iniciada antes. Cambiar/desconectar se bloquea con
trabajos ENQUEUED/RUNNING/BLOCKED. Se conservan grants previos para no romper
inputs históricos; una conexión no borra recibos ni archivos.

Si el permiso de user se revoca, se limpian raíz y proyecciones, se mantienen
los marcadores de revocación y se pide reconectar. No se muestra conectado si
falta permiso de escritura. Los getters utilizan applicationContext y no una
Activity: el engine del overlay puede consultar el destino en background.

## Migración

- Un user ya guardado por Biblioteca se reutiliza y deriva ambos destinos.
- Un permiso antiguo que realmente incluya user puede promoverse sin picker.
- Permisos antiguos solo a mods o dynos/packs NO conceden acceso al padre:
  siguen funcionando hasta que el usuario conecte user una vez.
- La migración se pospone durante trabajos activos y se reintenta al terminar
  o al reanudar la app. Las selecciones previas no se borran por cancelar picker.
- Cambiar carpeta confirma un único conjunto de proyecciones. Un fallo de
  guardado restaura las preferencias anteriores.

## UX y flujo vertical

Inicio ofrece una tarjeta opcional, sin abrir exploradores automáticamente.
«Ahora no» se guarda y deja el catálogo usable. Ajustes sustituye dos selectores
por una tarjeta común con estados de carpeta, config y candidato ROM. Biblioteca
usa la misma guía antes de abrir el selector. Desconectar requiere explicación
y confirmación, y conserva recursos ya preparados de temas.

Seleccionar Mario 64/SM64 Intro reutiliza primero los recursos privados existentes.
Si faltan, explica la preparación. Si falta conexión, abre la guía de user; si
ya existe, ofrece Preparar/Ahora no. No guarda el tema hasta terminar la
preparación. Cancelación o fallo conserva la apariencia anterior.

`MarioAssetsPlugin` lee primero baserom.us.z64 y después hasta ocho candidatos
.z64 directos, sin búsqueda recursiva. Valida exactamente 8 MiB y MD5 US, con
lectura cancelable y conversión en executor. Reutiliza el decoder/fuentes v2 y
el commit atómico de generación existente. No conserva la ROM, no escribe en
ella, no añade permisos generales ni vuelve a importar en cada arranque.
Sin ROM compatible informa cómo prepararla en SM64CoopDX. `importFile` queda
como contrato nativo de compatibilidad, sin botón automático en el flujo nuevo.

## Sincronización

`GameFolderService` recibe snapshots, `gameFolderProvider` es proyección del
engine principal. Cambios confirmados/migración/revocación invalidan la Biblioteca
mediante `ModInstaller.libraryInvalidations`. Sus consumidores refrescan el
scanner/verificación y `OverlayBridge` transmite la proyección al segundo engine.
El overlay no comparte providers ni singletons Dart con el principal; sus
instalaciones consultan la misma autoridad Kotlin y capturan destinos correctos.

`GameFolderCard` refresca al reanudar. El notifier observa el paso de Workers
activos a inactivos para completar migración diferida; el listener vive con ref.
Futures no esperados de initialize/resume/terminal refresh capturan errores en
refresh. Widget observers se retiran en dispose. ROM mantiene su cancelación y
coordinador global de resultados. No hay nuevos caches de rutas en Workers.

## Validación requerida

Pruebas Kotlin del resolver con IDs opacos, hijos inexistentes y destinos del
juego. Pruebas Flutter de selección simultánea/cancelación/error. Toda la suite
existente debe conservar análisis, identidad, WorkManager y flujo de activación.
Termux carece de Flutter/Dart; generación de cinco ARB y formato se obtienen del
runner, no se editan Dart generados a mano. Kotlin se compila en Actions.

Matriz física: instalación nueva y migrada; selección/cancelación/carpeta ajena;
user con/sin config y ROM; ROM inválida y válida con nombre alternativo; permisos
revocados; cambio de carpeta con Worker activo; mods/DynOS/Touch Controls/OMM
normal y DynOS/VIP/Render96; app y overlay; reinicio/rotación/cierre; dos
operaciones paralelas y cancelar una. Confirmar destino físico y recibos reales.
