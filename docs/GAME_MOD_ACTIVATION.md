# Activación de mods del juego desde Biblioteca

Implementación para `custom-themes`, candidata a `1.8.3+22`. No constituye una
publicación. El clon `sm64coopdx/` es material de referencia excluido de Git;
no se modifica ni se distribuye con SM64CDPY.

## Plan y alcance

1. Contrastar descubrimiento e identidad con el juego.
2. Autorizar la carpeta `user` con SAF y comprobar su relación con `mods`.
3. Implementar un editor que solo posea las entradas `enable-mod:`.
4. Serializar las operaciones en Android y confirmar cada escritura.
5. Mostrar unidades reales del juego en Biblioteca, independientes de recibos.
6. Manejar cancelación, conflictos, permisos, recuperación y ciclo de vida.
7. Añadir pruebas de contrato, traducciones y validación CI.
8. Probar en Android antes de aprobar la versión oficial.

La implementación cubre mods Lua locales normales. DynOS y Touch Controls
utilizan `dynos-pack:` y no reciben este control. Una instalación OMM, VIP o
Render96 aparece si produce una unidad Lua válida en la carpeta normal de mods.
Un ZIP/recibo puede contener varias unidades: no se inventa un switch global
por descarga. La lista muestra cada unidad encontrada por el contrato del juego.

## Contrato observado

Referencia: clon del juego en revisión `99c8d21abe4d24649b508d0f216c4359ed5d2a7a`.

- `src/pc/configfile.c`: lectura de `enable-mod:`, cola y escritura de habilitados.
- `src/pc/mods/mods.c`: enumera entradas inmediatas de `mods`; `mods_enable`
  compara `relativePath` con `strcmp`. La carpeta del usuario gana ante un
  nombre duplicado encontrado posteriormente entre recursos del juego.
- `src/pc/mods/mod.c`: admite archivos `.lua` inmediatos y carpetas inmediatas
  con `main.lua`; conserva como identidad el nombre real, no `-- name:`.
- `src/pc/mods/mods_utils.c`: ignora nombres no portables/ocultos; compara tokens
  separados por espacios del campo `-- incompatible:` y fuerza desactivación
  cuando el tamaño alcanza `35 * 1048576` bytes.
- `src/pc/djui/djui_panel_host_mods.c`: advertencia al alcanzar diez habilitados;
  no representa un máximo rígido de diez.

Ejemplo: `mods/My Mod/main.lua` corresponde a `enable-mod: My Mod`; un archivo
`mods/extra.lua` corresponde a `enable-mod: extra.lua`. Desactivar elimina las
entradas coincidentes. No existe `disable-mod:` ni un booleano después del nombre.
La comparación conserva mayúsculas. El lector del juego tokeniza hasta veinte
palabras, incluyendo la clave. Los nombres que no puede representar sin cambios
se excluyen, en lugar de escribir una selección que no pueda resolver.

Nuestro descubridor anterior acepta `mod.lua` y Lua anidado como indicios; eso
no demuestra que el juego cargue esa estructura. Por eso la nueva sección
**Mods del juego** enumera unidades válidas directamente desde `user/mods` y no
transforma automáticamente `DiscoveredInstallation.entryPath` en una identidad.
Los recibos, el historial y la detección anterior conservan sus contratos.

## Permisos y selección

Se usa `ACTION_OPEN_DOCUMENT_TREE` con lectura/escritura y permiso persistente,
no acceso general a todos los archivos. La carpeta seleccionada debe llamarse
`user`, contener `sm64config.txt` legible/escribible y una carpeta `mods`.
Si ya existe una carpeta de instalación seleccionada, su document ID y autoridad
se comparan con `user/mods`. Una selección de otra instalación se rechaza.

La URI se guarda en las preferencias nativas `mod_installer_prefs`, clave
`game_user_tree_uri`. La selección no reemplaza silenciosamente la carpeta de
instalación. Cancelar el picker conserva la selección anterior. Seleccionar una
carpeta inválida tampoco la sustituye. Desconectar elimina esta preferencia y
libera el permiso cuando no es una URI compartida con otras selecciones.
Una concesión persistente revocada se descarta al comprobar el acceso.

No se asume la ruta absoluta `/sdcard/...`: SAF resuelve el documento elegido.
Si Android/proveedor no expone una ubicación, se comunica falta de acceso; no
se promete saltar restricciones de `Android/data` ni permisos del otro juego.
La carpeta normal compartida del port es el caso esperado.

Fuentes oficiales consultadas:

- [Android: documentos y archivos compartidos](https://developer.android.com/training/data-storage/shared/documents-files).
- [Android: proveedores de documentos](https://developer.android.com/guide/topics/providers/document-provider).

SAF permite acceso al árbol elegido y conservar su concesión; mover o borrar
el documento puede invalidar el acceso. El permiso de `mods` no concede por sí
solo acceso a su padre `user`.

## Lectura y edición

El archivo es la autoridad de selección persistida. La instantánea contiene
estado de acceso y unidades con `name`, `title`, `enabled`, `selectable` y
posibilidad de restaurar el respaldo. Nunca devuelve el archivo completo,
contraseñas ni otras preferencias a Flutter o a logs.

Cada modificación:

1. Revalida URI, archivo y relación de carpetas.
2. Lee la configuración actual y redescubre las identidades y encabezados.
3. Comprueba que no existen descargas/instalaciones activas en WorkManager.
4. Al activar, comprueba encabezados legibles, incompatibilidades y tamaño.
5. Elimina todas las entradas de la identidad solicitada; al activar añade una.
6. Conserva bytes de las líneas ajenas, finales LF/CRLF y comentarios.
7. Guarda el original en un `AtomicFile` privado antes de truncar el documento.
8. Relee el original para detectar una modificación concurrente previa a escribir.
9. Comprueba nuevamente WorkManager, escribe con descriptor `rwt`, flush y sync.
10. Relee los bytes y confirma la instantánea resultante antes de mostrar éxito.

Se rechaza configuración mayor de 256 KiB, UTF-8 inválido, BOM o NUL. Esta
versión no crea un archivo ausente ni convierte formatos desconocidos. Los
nombres admitidos son portables para el juego, con menos de 256 bytes y hasta
19 palabras después de la clave. La edición no cambia entradas de otros mods,
ban/moderator/save-name, ajustes ni `dynos-pack:`.

La comprobación de tamaño cuenta Lua/Luac recursivos y los tipos del juego en
`actors`, `data`, `textures`, `levels` y `sound`. Utiliza metadata de tamaño y un
presupuesto de 4000 documentos; no lee los recursos grandes para sumarlos.
Una ruta que no pueda comprobarse se rechaza conservadoramente al activar.
Se puede desactivar una identidad válida aunque su encabezado no sea legible.
Si no se pueden conocer los encabezados de las unidades de la carpeta, se
bloquean nuevas activaciones para no ignorar una incompatibilidad desconocida.

El respaldo privado se llama `game-mod-config-<hash-de-URI>.backup` y pertenece a la
URI exacta de configuración guardada en `game_mod_backup_document`. No reemplaza
`sm64config-backup.txt`, administrado por el juego. La restauración explícita
exige confirmación, verifica URI y escritura y restaura también otros ajustes.
No hay restauración automática que pudiera borrar un cambio concurrente del juego.

## Límites prácticos

El juego lee al arrancar y mantiene su estado en memoria. SM64CDPY no tiene un
canal IPC con el proceso del juego: el usuario debe cerrarlo antes de editar.
El diálogo comunica que se configura el próximo inicio. No afirma activación
inmediata dentro de una partida, ni controla selecciones de un servidor remoto.

El bloqueo nativo coordina los dos engines de SM64CDPY, no al juego. SAF no ofrece
una transacción atómica compartida con sus escrituras C. La relectura reduce
conflictos pero no elimina la carrera entre comprobación y escritura. Una nueva
instalación encolada justo después de comprobar WorkManager también debe evitarse;
la UI bloquea la edición mientras hay operaciones activas y el servidor nativo
revalida antes de escribir, sin modificar el protocolo existente de Workers.

El tamaño puede cambiar si el juego genera recursos; se comprueba el contenido
actual accesible. Los recursos internos del APK del juego no son accesibles con
este árbol y no se enumeran. Sus entradas existentes se preservan. No se copia
la ejecución Lua, generación DynOS, validación de partida ni carga del juego.

## Archivos y responsabilidades

| Archivo | Responsabilidad |
|---|---|
| `GameModConfig.kt` | Parser de identidades y edición de líneas ajenas intactas. |
| `GameModActivationStore.kt` | SAF, reglas, bloqueo, respaldo y confirmación. |
| `ModInstallerPlugin.kt` | Picker, callbacks y operaciones fuera del hilo principal. |
| `GameModConfigTest.kt` | Contrato del parser/editor y nombres no representables. |
| `lib/services/game_mod_activation.dart` | Modelos de transporte y MethodChannel. |
| `game_mod_activation_provider.dart` | Proyección observable, guardado confirmado y exclusión de peticiones. |
| `game_mod_activation_panel.dart` | Sección de Biblioteca, selección, switches y recuperación. |
| `library_screen.dart` | Inserción de la sección y refresco manual. |
| `game_mod_activation_provider_test.dart` | Confirmación, fallo, concurrencia y cancelación del picker. |
| Cinco ARB | Mensajes equivalentes EN/ES/ES-419/PT/PT-BR. |
| Ambos workflows | Gen-l10n, formato, análisis, tests Flutter y tests Kotlin. |

## Rendimiento y ciclo de vida

Toda consulta SAF, metadata, respaldo y escritura corre en un thread nativo.
No hay lectura de configuración por cada tarjeta/render, ni polling continuo.
La proyección se actualiza al entrar en la pestaña, volver al primer plano,
completar una instalación o refrescar Biblioteca. Encabezados limitados a 64 KiB
se dejan de leer al terminar los comentarios; cada línea tiene límite de 800
caracteres. La lista admite hasta 500 entradas y presenta 20 controles por página.
El tamaño recursivo solo se comprueba para el mod que se intenta habilitar.

No se añade una caché persistente de activación que compita con el archivo.
Los dos engines utilizan el mismo coordinador SAF nativo. El overlay no ofrece
esta edición ni recibe una copia de la configuración; puede instalar mods con
el flujo existente, y la Biblioteca principal se refresca después del evento.
Las preferencias de interfaz, auto-install, recibos y WorkManager no se alteran.

La UI bloquea durante diálogos/operaciones, comprueba `mounted` después de
esperas, retira el observer de ciclo de vida y cancela su suscripción al salir.
El picker pendiente sobrevive a rotación del engine/plugin y termina con error
si su Activity se desconecta definitivamente. Futures de edición se esperan;
refrescos de eventos/ciclo de vida usan `unawaited` con captura interna de errores.

## Validación

En Termux no hay Flutter/Dart ni toolchain Android funcional: no se afirma una
compilación local. CI ejecuta `flutter gen-l10n`, formato, análisis, tests Flutter,
`:app:testReleaseUnitTest` y compilación APK. Mantiene logs/patch de fuentes.

Pruebas automáticas nuevas: comparación exacta, espacios, comentarios, CRLF,
última línea sin salto, entradas repetidas, conservación de ajustes/packs,
nombres rechazados, estado confirmado, exclusión de escritura simultánea,
error con reintento y picker cancelado.

Matriz física pendiente antes de release:

- Carpeta correcta/incorrecta, mods de otra instalación, cancelar selección.
- Permiso revocado, archivo borrado, fallo de escritura y restauración tras reinicio.
- Carpeta con main.lua, Lua suelto, mod.lua solamente y carpetas anidadas inválidas.
- Activar/desactivar; cerrar y abrir el juego y comprobar su menú de mods.
- Dos incompatibles: desactivar primero, habilitar segundo; diez habilitados.
- Mod que alcance 35 MiB y proveedor con tamaño desconocido.
- Dos switches rápidos, instalación desde overlay, cambios desde el juego,
  rotación durante picker, minimizar, volver y muerte del proceso.
- LF/CRLF, nombres con espacios y configuración con entradas ajenas.
- Biblioteca grande: medir tiempos reales sin atribuir rendimiento de dispositivo
  a una inspección estática; ajustar presupuestos si hace falta.

## Verificación de sincronización de estado

- Escritores: juego y editor nativo; lector principal: juego al arrancar y
  servicio nativo de SM64CDPY. Flutter consume exclusivamente instantáneas.
- Fuente de verdad: archivo seleccionado para próximos inicios; memoria del
  juego para su sesión. No se presentan como una única memoria sincronizada.
- Proyección: vuelve a leer después de guardar y ante los disparadores de refresco.
- Caches: estado Riverpod reemplazable; no nueva autoridad en Hive/SharedPreferences.
- Futures no esperados: únicamente refrescos con captura de errores y teardown
  de suscripción como patrón existente; escrituras y confirmaciones se esperan.
- Hermanos: catálogo/recibos externos y propios convergen en unidades Lua;
  DynOS/Touch no usan este contrato; overlay sigue instalando con WorkManager.

## Evidencia CI inicial

La prueba #180 confirmó análisis Flutter y 68 tests Flutter. El nuevo paso
nativo detectó que el wrapper no está versionado y aún no existía antes del
build. Se corrigió el orden: Flutter prepara wrapper/local.properties y compila;
luego `:app:testReleaseUnitTest` reutiliza la variante release y bloquea la
subida/publicación si falla. No se añadió una compilación debug redundante.

## Integración visual de Biblioteca

`Mods del juego` es ahora una pestaña propia, como vista principal de
Biblioteca, con el mismo selector horizontal y contador que las otras vistas.
El selector queda accesible incluso si falla la lectura de recibos; la edición
del juego depende de su propia instantánea. `?view=game-mods` abre esa vista.
Al refrescarla no se fuerza una actualización de catálogos ni otro escaneo de
recibos. Entrar en la vista solicita una lectura actual de la configuración.

El encabezado resume activados/total. La búsqueda local utiliza título e
identidad, sin nuevas consultas SAF ni llamadas de red. Los filtros Todos,
Activados y Desactivados reutilizan `SkewChip`; la búsqueda/filtro devuelve un
estado vacío contextual. La paginación conserva veinte tarjetas por incremento.

Las tarjetas, acciones, avisos, diálogos y switches consumen los roles de
`RetroTheme`, sin comparar IDs concretos. Manga utiliza bordes duros, sombra
desplazada y etiquetas en mayúsculas. Mario utiliza sus radios, tratamiento
biselado, sombras y selección con estrella. Los colores de texto sobre fondos
rellenos usan `inkOnAccent`; las superficies usan `ink`/`inkDim`. No hay un
ExpansionTile genérico antes de las pestañas ni nombres de archivo como texto
principal repetido. Selección, desconexión y respaldo viven en el menú del
encabezado; la primera configuración y los errores ofrecen acciones visibles.

La confirmación de juego cerrado se solicita antes de la primera edición de
la visita. Se recuerda solo en el State de la vista, se pierde al salir y se
reinicia al volver al primer plano o gestionar el acceso. No es una preferencia
persistente y nunca sustituye la verificación nativa de cada escritura. La
restauración continúa pidiendo confirmación siempre. La tarjeta solicitada
muestra progreso y todos los switches se bloquean hasta recibir confirmación.
El éxito usa `AppSnackbar`; ante fallo se mantiene el estado confirmado y se
conservan las opciones de recuperación.

Las acciones ofrecen objetivo táctil mínimo de 48 dp, texto flexible, nombres
semánticos para switches y títulos de diálogo anunciables. Tests de widget
comprueban ambos diseños en claro/oscuro, ancho de 320 px, escala de texto 1.6,
filtrado sin escrituras, espera del guardado y confirmación de nuevo al reanudar.

Validación física pendiente: aspecto de ambas variantes, teclado/búsqueda,
navegación entre pestañas, lectores de pantalla y cambio en el menú del juego.
La funcionalidad anterior fue confirmada por el usuario y la prueba #181
compiló APK y pasó tests Flutter/Kotlin. Esta revisión visual se valida aparte.

## Fusión de Detectados en Mods del juego

La vista visible Detectados y `DetectedInstallationCard` se retiraron. Biblioteca
conserva Instalados (recibos), Mods del juego (unidades físicas y activación),
Actualizaciones e Historial. El enlace antiguo `?view=detected` abre Mods del juego.
Los textos obsoletos se retiran de los cinco ARB mediante generación normal en CI.

Prioridad: `GameModActivationStore` decide qué existe como mod del juego, con las
reglas exactas de Lua inmediato/carpeta con main.lua. El nuevo lector compartido
`LuaModMetadata` recibe el mismo encabezado que ya se leyó para incompatibilidades.
Migra nombre limpio, autor, categoría, descripción y versión detectada. No consulta
de nuevo SAF y no busca un supuesto equivalente por título entre descubrimientos.
El nombre físico sigue siendo la identidad de `enable-mod:`; campos informativos
no afectan activación, tamaño, incompatibilidades o política de actualizaciones.

El juego reconoce nombre/categoría/descripcion e incompatibilidades en comentarios
iniciales. Autor y versión son información adicional que publica el mod: su ausencia
se representa omitiendo el campo. La versión puede extraerse del título, descripción
o filename cuando hay un marcador reconocible; no se atribuye un ID de catálogo ni
se ejecuta Lua para obtenerla. Los formatos y colores se limpian solo para mostrar.
Los metadatos permanecen acotados: nombre/categoría 64, autor 128, descripción 800.

La misma tarjeta muestra autor, categoría y versión cuando existen. Una descripción
corta lleva a un panel de detalles de solo lectura con el texto completo y la
identidad real; abrirlo no escribe configuración. La búsqueda local ahora incluye
esos campos. Se mantienen ambos diseños, filtros de activación, contador y paginación.
Mods con estructuras inválidas que el descubridor anterior aceptaba como indicios
no se convierten en mods controlables. DynOS no se mezcla con este contrato Lua.

Se eliminan los disparadores de escaneo antiguo en navegación, refresco, cambio de
carpeta y olvido de recibos. `ModInstallerPlugin` entrega recibos sin adjuntar su
caché de descubrimiento; la proyección Hive deja de arrastrar sus errores/datos en
la siguiente sincronización. El parser, entidad y endpoint antiguos siguen leyendo
el formato previo para compatibilidad técnica y tests, pero no alimentan la UI.
Olvidar un recibo conserva los archivos: Mods del juego los enumera independientemente.
No se añade una caché de metadatos ni otra autoridad de activación.

Tests añadidos: metadata inicial limpia/acotada, ausencia de campos, búsqueda por
autor y detalles sin escritura; DTO compatible con instantáneas antiguas e identidad
separada del título. El test de olvido comprueba que conserva historial sin volver
a escanear archivos. Pendiente físico: seis mods en una sola vista, autor/versiones,
detalles largos, refresco y activación tras abrir el juego.

Mods del juego es la primera pestaña y la vista predeterminada. Instalados conserva
los recibos de SM64CDPY y puede abrirse explícitamente con `?view=installed`.

## Tipografía Mario 64

La vista y los detalles utilizan roles de `RetroTheme`: TypefaceMario64 solo para
encabezados de Mario 64; el texto descriptivo conserva la fuente predeterminada.
Los tests de pantalla estrecha/texto ampliado cargan los archivos de fuente reales,
en lugar de comprobar únicamente la tipografía de prueba del runner.
