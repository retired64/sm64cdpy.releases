# Jugador 3D: arquitectura y operación

## Apertura del editor y snapshot persistente — 2026-10-19

Se separa el tiempo para mostrar el perfil del tiempo de lectura SAF y del
renderizador. `getCachedPlayerProfile` lee `PlayerProfileCache` desde preferencias
Android privadas, sin listar carpetas ni esperar el bloqueo global de SAF.
El envelope v1 está acotado, ligado a URI user + raíz autorizada, comprueba
permiso persistente y estructura básica. No contiene ROM, imágenes ni WebViews.
Es caché descartable de presentación, no respaldo ni autoridad del juego.

`getPlayerProfile` lee configuración/revisión sin escanear paletas;
`getPlayerPalettes` completa el listado después. Antes, `playerSnapshot` hacía
ambas tareas bajo el mismo bloqueo y Flutter esperaba todo sin datos visibles.
Riverpod publica el snapshot primero y refresca sin retirar el editor. Busy
representa una mutación; refreshing representa verificación, no un falso guardado.
Sin caché válida, la primera lectura todavía necesita acceso real al proveedor.

Escritores: lecturas confirmadas, apply, restore y operaciones de paletas nativas
actualizan el snapshot. GameFolderStore lo elimina al conectar/desconectar;
cambio de identidad, falta de permiso, estructura corrupta y errores de lectura
lo invalidan. Cambios externos del juego se detectan en refresh al abrir por
primera vez el proceso, al reanudar Jugador y al actualizar manualmente.
No se garantizan milisegundos concretos ni se cachean permisos como si fueran
permanentes. Una llamada cache fallida no impide consultar el juego.

Mientras se verifica se permite editar, pero aplicar, restaurar y escribir
paletas requieren revisión disponible y refresh terminado. Si se edita mientras
llega una respuesta, se conserva borrador, perfil base y revisión original:
apply nativo vuelve a leer y rechaza conflictos, incluso con un borrador iniciado
desde caché. Una lectura fallida retira autorización para escribir. Lectura
válida sin perfil retira el snapshot visible; no sigue ofreciendo una carpeta
desconectada como operativa. La revisión de una respuesta antigua nunca gana a
una mutación más reciente; los listados vacíos sí reemplazan paletas anteriores.
Si solo cambian otras claves del config y el perfil base sigue siendo idéntico,
se adopta la revisión nueva para evitar conflictos innecesarios. Aplicar un
perfil reutiliza el listado de paletas conocido: esa escritura no modifica los
INI y no necesita repetir su escaneo completo.

Deduplicación de cargas también para force; errores inesperados liberan estado
de carga. No se incorporan Futures fire-and-forget nuevos. El refresh de lifecycle
ya existente captura errores dentro del notifier. Proyecciones main y overlay
no comparten memoria: el nuevo snapshot vive en Android y el overlay no lo
consume. No se cambian eventos de instalación, mods, DynOS o Touch Controls.
Se revisaron importación de assets ROM, caché de Player3DSource y cambios de
carpeta: continúan independientes y la preparación 3D no bloquea los controles.

Pruebas añadidas en `player_profile_provider_test.dart`: snapshot antes de SAF,
deduplicación, edición durante refresh con conflicto, respuestas tardías de
paletas, pérdida de carpeta, caché corrupta y excepciones inesperadas. Pendiente
ejecutar Flutter/Android en CI y medir arranque frío en teléfono con permisos
válidos/revocados, paletas vacías/numerosas, edición externa y rotación.
Termux no dispone de flutter, dart ni android/gradlew; diff-check sí es local.
La clase PlayerProfileCache compila contra stubs con el compilador Kotlin
disponible; esto comprueba sintaxis/tipos de esa clase, no compatibilidad Android
completa ni comportamiento de SharedPreferences/SAF. Manifiesto JSON válido.

## Decisión

La pantalla Jugador reemplaza completamente la previsualización PNG 2.5D por un
pipeline 3D compatible con SM64CoopDX. No distribuye contenido de Nintendo ni de
SM64CoopDX: reconstruye el personaje durante la ejecución usando la ROM USA
autorizada por el usuario y `libmain.so` del juego instalado.

La implementación deliberadamente no usa el segmento `player_model.bin` del
tema Mario. Ese recurso queda como compatibilidad de generaciones de tema v3 y
no es una segunda fuente de verdad para Jugador.

## Contrato técnico

| Área | Contrato |
|---|---|
| Render | Three.js r186, cámara en perspectiva y shaders N64 |
| Modelos | `mario_geo`, `luigi_geo`, `toad_player_geo`, `waluigi_geo`, `wario_geo` |
| Perfil | claves `coop_player_*` en `user/sm64config.txt` |
| Entradas locales | `libmain.so` del juego y `baserom.us.z64` autorizada |

El renderer ofrece drag horizontal, inercia, reposo articulado, actualización de
colores por uniformes y liberación explícita del contexto WebGL. Android extrae
`lib/<ABI>/libmain.so` desde `com.maniscat2.sm64coopdx` y combina ese binario con
`baserom.us.z64` sin publicar copias en el almacenamiento del usuario.

## Flujo implementado

```text
PlayerScreen / Riverpod draft
        │ modelo 0..4 + ocho colores RGB
        ▼
Player3DPreview (AndroidView)
        │ canal por viewId
        ▼
Player3DPlugin / WebView local aislado
        ├── Player3DSource ── APK instalado ── libmain.so
        ├── Player3DSource ── SAF raíz juego ─ baserom.us.z64 validada
        └── https://player3d.local
              ├── parser GeoLayout/Fast3D
              ├── pose y modelo del personaje
              └── Three.js + shaders N64 ── canvas interactivo
```

`Player3DSource` copia ambos insumos a caché privada mediante archivo temporal y
rename. La biblioteca se limita a 160 MiB y se invalida con la ruta, tamaño y
fecha de los APK base/split. La ROM debe tener el tamaño y MD5 ya aceptados por
`MarioRomDecoder`; se consideran como máximo ocho `.z64` de la raíz SAF y se
prioriza `baserom.us.z64`.

El WebView no tiene acceso a archivos ni `content://`, habilita almacenamiento del origen local para IndexedDB, no
acepta contenido mixto y bloquea recursos/navegación fuera del host virtual
`player3d.local`. Solo expone once recursos locales auditados: HTML, siete módulos JavaScript,
la identidad de origen y los dos binarios efímeros. Los streams binarios no se insertan en
JavaScript ni se escriben en el árbol visible del usuario.

Al primer render se analiza el binario y la ROM una sola vez por PlatformView.
Cambiar colores llama `setColors` y actualiza uniformes sin reconstruir geometría.
Cambiar personaje reconstruye los grupos usando el parser ya cargado y un lector
de pose nuevo: ese lector es consumible y reutilizarlo desplaza las articulaciones
del siguiente personaje. Se retienen como máximo dos modelos reconstruidos para
acelerar alternancias sin agotar memoria en equipos modestos. Al salir,
Flutter desconecta el canal y Android detiene/destruye el WebView; el renderer
libera geometrías, materiales, texturas y fuerza la pérdida del contexto WebGL.

El modelo derivado de cada personaje se persiste en IndexedDB bajo una huella
que combina la versión del esquema del renderer y el sello del APK instalado.
En visitas posteriores el WebView reconstruye Three.js desde ese modelo ya
procesado, sin volver a leer ni analizar `libmain.so` y la ROM. También conserva
un fotograma WebP por modelo y paleta: se muestra en cuanto abre el visor y se
reemplaza silenciosamente por el canvas interactivo. Cambiar el APK del juego o
el esquema del renderer produce una huella nueva y deja de reutilizar entradas
incompatibles. Los binarios y perfiles originales continúan siendo las fuentes
de verdad; IndexedDB solo contiene una proyección regenerable.

## Perfil y persistencia

| índice | personaje |
|---:|---|
| 0 | Mario |
| 1 | Luigi |
| 2 | Toad |
| 3 | Waluigi |
| 4 | Wario |

La selección modifica el borrador Riverpod inmediatamente para actualizar el
preview. No toca el juego hasta **Aplicar**. Después, nombre, modelo y ocho
colores viajan juntos por `PlayerProfileService` a
`GameModActivationStore.applyPlayer`. El guardado conserva líneas ajenas,
respeta CRLF/LF, usa la revisión digest compare-and-swap, crea el respaldo común
y relee el archivo para confirmar lo escrito. `sm64config.txt` confirmado es la
fuente de verdad; el canvas nunca persiste estado del juego.

## Rendimiento y experiencia

- La carga costosa sucede una vez al crear la vista, no en cada cambio de color.
- El PlatformView solicita keep-alive dentro del sliver: desplazarlo fuera de la
  pantalla ya no destruye WebView, parser, modelos ni contexto WebGL.
- `IntersectionObserver` pausa el loop de frames fuera del viewport y lo reanuda
  sobre el mismo canvas al volver, sin círculo de carga ni reconstrucción.
- Player aloja esa única instancia en un `SliverPersistentHeader`: el preview
  comienza a tamaño completo y se contrae hasta 158 px, alineado a la derecha,
  para seguir mostrando cambios de paleta mientras se editan controles inferiores.
  La transición no clona ni vuelve a crear el PlatformView.
- El render se limita a 30 FPS y pixel ratio 1.5; contextos cuyo límite de textura
  es de 4096 o menor usan escala 0.7, calculada una vez al crear el visor.
  Esto es un presupuesto conservador, no un benchmark de GPU.
- Los cambios de paleta no muestran una pantalla global de carga.
- El overlay de carga pertenece solo al rectángulo del preview.
- Un error de juego ausente, permiso, ROM o WebGL deja el editor disponible y
  muestra el mensaje localizado de vista previa no disponible.
- El estado nativo se puede consultar con `getState`, evitando perder un error
  emitido antes de que Flutter conecte su handler.
- La vista respeta el renderer original: giro por drag, inercia y
  adaptación de FPS/pixel ratio. El reposo articula el personaje; no lo hace girar solo.

## Archivos responsables

- `lib/presentation/screens/player_screen.dart`: composición y selector de modelo.
- `lib/presentation/widgets/player_3d_preview.dart`: PlatformView y estado visual.
- `android/app/src/main/kotlin/mods/sm64cdpy/Player3DPlugin.kt`: aislamiento WebView.
- `android/app/src/main/kotlin/mods/sm64cdpy/Player3DSource.kt`: insumos verificados.
- `assets/player3d/app.js`: ciclo de vida parser/renderer y actualización en vivo.
- `assets/player3d/NOTICE.md`: procedencia, hashes y licencia.

## Matriz de aceptación pendiente en dispositivo

1. Mario/Luigi/Toad/Waluigi/Wario aparecen y giran sin geometría faltante.
2. Cada uno de los ocho colores cambia en vivo sin recargar la pantalla.
3. Aplicar, cerrar app, iniciar juego y volver conserva modelo/nombre/paleta.
4. Juego ausente, ROM ausente/incorrecta y permiso SAF revocado degradan con UI útil.
5. Rotación, background/foreground y 20 entradas/salidas no filtran contextos WebGL.
6. Validar Android 7, 10, 13, 14 y 16 en GPU baja/media/alta.

## Iconos del selector de personaje

Jugador usa los cinco PNG originales del usuario en `assets/icons/player/`,
registrados en pubspec. La correspondencia conserva los IDs del juego:
0 Mario, 1 Luigi, 2 Toad, 3 Waluigi, 4 Wario. Cada imagen nativa de 16×16
se muestra a 32×32 con vecino más cercano, sin tintes ni animaciones.
`Image.asset` reutiliza ImageCache de Flutter con decodificación limitada a
16×16 (1 KiB RGBA por icono; cinco iconos suman 5 KiB sin contar overhead).
No hay lectura externa, requests, timers, precarga masiva ni cache persistente.
El nombre proporciona la etiqueta accesible y la imagen es decorativa.

SkewChip acepta un leading opcional; los demás consumidores mantienen iconos
Material y el mismo comportamiento. El selector crece a 64 puntos para respetar
el tamaño de los iconos y área táctil, manteniendo scroll horizontal y colores
de selección de cada tema. No cambia perfil, guardado, renderer 3D ni su cache.
La optimización del spinner/carga de entrada se pospone por petición del usuario.
Validación física pendiente: nombres e iconos, selección y texto ampliado.

Validación de iconos: cinco originales copiados byte a byte, 1803 bytes en total,
IHDR de 16×16 verificado. [Testing 39342619343](https://github.com/retired64/sm64cdpy.releases/actions/runs/39342619343)
aprobó generación, formato, análisis y pruebas Flutter para `f929c9b`.
Los Dart modificados ya coinciden con el formato del runner; no se importa el
reformateo de archivos ajenos. APK arm64 en compilación al registrar esta nota.
El rendimiento real y el aspecto siguen pendientes de comprobación en teléfono.

Build de seguimiento validada: [Testing 39344333533](https://github.com/retired64/sm64cdpy.releases/actions/runs/39344333533)
completó APK arm64 y pruebas nativas con los retratos incluidos en el código y
pubspec. El fallo de 39342619343 era una descarga NDK inválida; no se revirtió
la integración de iconos ni se modificó el spinner. Artifact publicado por CI:
`cdpy-f10f833-TESTING`. Sigue pendiente revisión en teléfono.


## Reposo articulado JavaScript/WebGL — 2026-11-03

Integración en `r2-phase6-flutter-fallback`, adaptada de `launcher-coopdx`.
Se conserva Flutter para el editor y Android para el origen autorizado y WebView;
el render y la animación siguen siendo JavaScript/WebGL, sin nuevo motor nativo.
No cambian paquete, versión, permisos SAF ni escritura de `sm64config.txt`.

### Contrato de modelo y animación

- `player3d-index.js`: GameParser ELF/AArch64 recuperado del bundle anterior,
  aislado de su bootstrap de aplicación. Conserva relocaciones y lectura ROM;
  la descompresión MIO0 valida tamaño, límites y referencias hacia atrás.
- `player3d-model.js`: GeoLayout/Fast3D produce esquema v4 con nodos
  `{parent, local, joint}` y grupos de geometría en espacio local con `node`.
  La jerarquía sigue OPEN/CLOSE_NODE y conserva las ramas elegidas del modelo.
  Los lotes incluyen la identidad del nodo para no fusionar partes articuladas.
- `player3d-clips.js`: lee la tabla USA `0x4EC000`, clips `0xC3/0xC4/0xC5`
  (izquierda, derecha, centro), 20 articulaciones y 30 FPS. Exporta esquema v2
  con rotaciones y traslación en int16 little-endian/base64. Las entradas ROM
  son big-endian. Límites de fotogramas, canales y buffers se validan.
- `player3d-renderer.js`: árbol Object3D, interpolación quaternion por el camino
  corto y transición de 100 ms entre clips. La traslación del primer joint se
  mezcla junto con la rotación: omitirla hace que los pies parezcan saltar.
  `createIdleMotion` comparte el algoritmo real con las pruebas CPU sin GPU.
- La preferencia WebView `prefers-reduced-motion` fija el primer fotograma;
  ausencia/corrupción de clips conserva la pose de referencia. El editor sigue
  disponible si falla la vista. No se añaden mensajes visibles sin localizar:
  Flutter conserva sus estados y textos existentes.

### Fuentes de verdad, concurrencia y caché

ROM validada y APK instalado son las fuentes del modelo; el perfil confirmado
sigue viniendo de `sm64config.txt`. El render solo proyecta el borrador Flutter.
No se comparte estado con el engine del overlay ni se toca WorkManager.

`Player3DSource` usa SHA-256 del sello de APK base/splits para el nombre privado
de biblioteca. La identidad incorpora el MD5 de la ROM USA admitida y el
esquema articulado. IndexedDB usa `player3d-rig-v4-clips-v2`, elimina entradas
incompatibles y valida modelos/clips al leer; no reutiliza geometría plana v2.
La ROM admitida tiene digest fijo; otra ROM no se considera compatible por usar
el mismo nombre de archivo. Los clips se comparten entre los cinco personajes,
los modelos en memoria se limitan a dos y todo es regenerable.

Solo hay una carga/extracción activa por vista. Las peticiones sucesivas se
agrupan conservando la última, con generación comprobada después de cada espera.
Cambios solo de paleta actualizan uniformes sin reconstruir el modelo. Los
fotogramas WebP se capturan después de terminar la transición de color, con
identidad y generación verificadas, para no etiquetar una paleta intermedia
como si fuera la definitiva. Fallos/cuota de IndexedDB no bloquean el visor.

`bridgeReady` y entrega de perfil se actualizan en el hilo UI Android.
`IntersectionObserver` y `visibilitychange` detienen el loop fuera de vista o
con documento oculto; al reanudar se reinicia el reloj para evitar saltos de tiempo.
`pagehide` invalida peticiones, cancela temporizador/RAF de snapshot, libera el
renderer y cierra IndexedDB. Los contextos perdidos después de cambiar la paleta
siguen produciendo error y liberación del visor actual, sin falso `ready`.
Las escrituras opcionales de snapshots y el cierre de cache capturan sus errores;
los eventos públicos conservan `bridge-ready/loading/preview/ready/error`.

### Validación reproducible

Con Node 22 o superior, sin descargar ROM ni APK:

```sh
node --test test/player3d/*.test.mjs
```

Las pruebas normales generan datos sintéticos: clips, límites, signo/endian,
jerarquía, rotaciones, interpolación, movimiento reducido, fallos, actualizaciones
obsoletas, cierre y lista de recursos Android. Los dos workflows Android ejecutan
esta suite antes de preparar Flutter. No reemplaza Flutter/Gradle ni pruebas GPU.

Prueba adicional con insumos privados existentes (nunca se suben como fixtures):

```sh
PLAYER3D_GAME=/path/to/libmain.so PLAYER3D_ROM=/path/to/baserom.us.z64 \
  node --test test/player3d/real-inputs.test.mjs
```

Ejecutada localmente con ELF Android y ROM USA: cinco modelos con 21 nodos,
60 ángulos de referencia y tres clips de 30 fotogramas. Se verifican 300 pasos
por personaje con matrices finitas y la compensación de pies de Mario: excursión
sin traslación mayor de 4 unidades y con ella menor de 1.5 por clip.
La geometría de referencia coincide con la extracción plana anterior dentro de
0.001 unidades en los cinco modelos; la comparación se hizo localmente sin
incorporar material derivado al repositorio.

Pendiente en APK/dispositivo: aspecto de los cinco personajes, texturas y shaders
Adreno/Mali, fluidez/batería, texto ampliado y preview contraído, desplazamiento,
20 cambios de modelo, paletas, Aplicar, background/foreground, rotación, permisos
revocados y WebView sin almacenamiento disponible. Este entorno carece de
Flutter/Dart y del script `android/gradlew`; no se declara un APK compilado aquí.

Validación local de esta integración: 16 pruebas JavaScript aprobadas, incluida
la prueba con insumos privados; 16 pruebas Python de scripts aprobadas; Kotlin
modificado compilado contra API Android y stubs mínimos Flutter/proyecto. Esta
última comprobación solo cubre sintaxis/tipos, no la integración Gradle real.
`git diff --check` correcto. Flutter analyze y Gradle completos no disponibles.


## Corrección de empaquetado y arranque — 2026-11-03

La primera build `bf4d54e` pasó compilación y pruebas CPU, pero su APK no contenía
`assets/flutter_assets/assets/player3d/vendor/three.core.js` ni `three.module.js`.
Se confirmó abriendo el APK descargado: la declaración `assets/player3d/` en
pubspec **no incluye subdirectorios recursivamente**. El grafo ESM fallaba antes
de ejecutar `app.js` y emitir `bridge-ready`, dejando la proyección Flutter en
loading. No era tiempo normal de extracción ni descarga de personajes.

Se declara `assets/player3d/vendor/` explícitamente. La prueba de recursos ahora
verifica también la declaración Flutter de cada dependencia, no solo su presencia
en disco y la lista permitida Android. `scripts/verify_player3d_assets.py` recorre
el grafo real desde HTML y comprueba presencia y bytes de los módulos dentro de
cada APK; ambos workflows lo ejecutan antes de subir artifacts/publicar.

HTML instala un manejador antes del módulo principal: errores de carga/rechazos
se reportan por el bridge existente como `error` con detalle técnico. Un límite
de arranque de 30 segundos evita loading permanente si nunca llega un resultado.
`ready/error/pagehide` retiran el temporizador; no se introducen estados nuevos
ni mensajes visibles sin localizar. La pantalla Flutter conserva sus textos de
vista previa no disponible. No cambia el perfil, sus caches de configuración,
el overlay ni WorkManager.

Regresiones: 19 pruebas Python aprobadas y 19 pruebas JS aprobadas, incluida
la adicional con insumos privados. El verificador rechaza el APK
`bf4d54e` precisamente por los dos módulos faltantes. Pendiente verificar el APK
corregido de Actions y el render real en teléfono. No se modifican claves,
versión, shaders ni datos de los personajes en esta corrección.
