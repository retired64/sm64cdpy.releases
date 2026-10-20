# Jugador 3D: arquitectura y operación

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

El renderer ofrece drag horizontal, inercia, giro automático, actualización de
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

El WebView no tiene acceso a archivos ni `content://`, no usa DOM storage, no
acepta contenido mixto y bloquea recursos/navegación fuera del host virtual
`player3d.local`. Solo expone seis recursos locales auditados: HTML, adaptador,
dos bundles y los dos binarios efímeros. Los streams binarios no se insertan en
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
- GPU Android Adreno/Mali/PowerVR entra en una clasificación móvil conservadora;
  los equipos débiles renderizan a escala 0.7 y el pixel ratio se limita a 1.5.
- Los cambios de paleta no muestran una pantalla global de carga.
- El overlay de carga pertenece solo al rectángulo del preview.
- Un error de juego ausente, permiso, ROM o WebGL deja el editor disponible y
  muestra el mensaje localizado de vista previa no disponible.
- El estado nativo se puede consultar con `getState`, evitando perder un error
  emitido antes de que Flutter conecte su handler.
- La vista respeta el renderer original: giro por drag, inercia, auto-rotación y
  adaptación de FPS/pixel ratio.

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
