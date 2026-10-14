# Mario 64: reconstrucción de menús con la ROM — versión 2

Rama `custom-themes`, Android, preparación de 1.8.3+22. El usuario comprobó que
la importación v1 funcionaba, pero sus 15 imágenes y opacidades 9–16 % dejaban
muchas superficies genéricas. V2 reemplaza esa política: escenas originales,
materiales opacos, marcos cuadrados, tipografías derivadas de ROM e iconografía
compartida en las 14 pantallas principales. No se modifica ni publica el juego.

## Flujo de selección

1. Ajustes → Tema de interfaz → Mario 64.
2. Sin un conjunto v2 completo, `AppearanceNotifier.selectThemeWithRom` abre la
   selección directa de ROM. No cambia aún el tema persistido; bloquea otra
   selección y conserva el diseño anterior mientras prepara recursos.
3. Android valida ROM, genera y verifica el conjunto privado completo; Flutter
   carga las fuentes. Solo entonces se confirma el tema en Hive.
4. Cancelación/error conserva tema y recursos anteriores, libera controles y
   no genera un falso error de guardado del tema. El coordinador ROM informa
   errores/éxito, incluso al navegar. La elección de tema pertenece al provider,
   no a la vida de la pantalla que abrió el selector.
5. Un conjunto ya preparado se reutiliza al seleccionar Mario; no pide la ROM
   en cada visita, cambio claro/oscuro o reapertura. La ROM no se guarda.

La selección de la carpeta `user` para configurar mods no concede acceso a su
padre. Se mantiene ACTION_OPEN_DOCUMENT, sin búsqueda automática de ROM,
MANAGE_EXTERNAL_STORAGE, permiso de escritura ni URI persistente nueva.

## Recursos y fuente exacta

Se generan **147 imágenes individuales + 4 imágenes compuestas + 3 fuentes**:
154 archivos privados. No se incluyen estos recursos en git, assets del APK,
fixtures ni publicaciones. Los manifiestos son direcciones/dimensiones, no arte.

| Recursos | Fuente del clon de referencia | Uso |
|---|---|---|
| Piedra clara/oscura, manos, imágenes Mario nuevo/guardado, File/Score/Sound/Copy/Erase y Course | `levels/menu/leveldata.c`, segmento US 0x2a65b0, 22255 bytes comprimidos | Material, cursor, navegación y vocabulario del selector original |
| 36 caracteres de menú IA8 8×8 | mismo archivo, offsets declarados para 0–9/A–Z | Fuente de controles y alfabeto completo para letras HUD ausentes |
| 21 letras HUD, 10 dígitos, estrella, moneda, cabeza Mario, flechas | `bin/segment2.c`, 0x108a40, 48390 bytes comprimidos | Encabezados a color, contadores e iconos |
| 62 caracteres de diálogo IA4 | mismo archivo, 0–9/A–Z/a–z | Fuente de texto general |
| Cielo Clouds, cielo BBH | `bin/clouds_skybox.c` (0x2c73d0, 35951), `bin/bbh_skybox.c` (0x2fb1b0, 27422) | Escenas clara/oscura 256×256 |
| panel_light/panel_dark | relieve de piedra de la ROM | Material opaco con luminancia ajustada para legibilidad |

Referencia Android del juego: `SDLActivity.java` elige documento y copia ROM para
`src/pc/rom_checker.cpp`; este habilita MD5 US vanilla. `src/pc/rom_assets.c` lee
segmentos y MIO0 en memoria. El manager usa un decoder acotado independiente,
no carga un engine del juego ni presupone que haya PNG exportados.

La ROM admitida sigue siendo **US vanilla .z64 big-endian de 8 MiB**, MD5
`20b854b239203baf6c961b850a4a51a2`. Regiones alternativas, ROM modificada, .v64/.n64
con otro byte order y ZIP se rechazan. El nombre del archivo no determina validez.

## Reconstrucción de fuentes y fondos

`MarioRomDecoder` convierte RGBA5551, IA8 e IA4. Para los diálogos no asume una
rotación a partir del PNG de extracción: lee el quad `vertex_ia8_char` del propio
segmento ROM (0x11c88), posiciones y coordenadas S/T big-endian, y muestrea sus
UV para obtener los glifos 8×16 como los display lists del juego.

Los skyboxes contienen 41 teselas 32×32. Su tabla tiene diez columnas (ocho reales
más dos de wrapping) y ocho filas; las tres últimas repiten la tesela 40. El
importador recompone las ocho columnas reales, conserva orientación y genera
los panoramas de 256×256. Flutter usa estas imágenes a resolución de pantalla,
con filtro nearest y sin cargar/renderizar geometría 3D.

`MarioPixelFont` crea TrueType desde los píxeles importados: contornos cuadrados,
cmap Unicode, glyf/loca, métricas, nombres y checksums. No contiene glifos dibujados
a mano ni bitmap Nintendo compilado. Las familias son:

- `MarioRomMenuV2`: letras/dígitos del selector; controles.
- `MarioRomDialogV2`: texto y descripciones con mayúsculas/minúsculas originales.
- `MarioRomHudV2`: títulos; las letras que no existen en HUD usan el alfabeto
  original de menú. También hay encabezados con bitmaps HUD a color.

Acentos y símbolos que la ROM US no contiene usan fallback Roboto, conservando
idioma y nombres del usuario. TypefaceMario64 queda como reserva para un conjunto
antiguo/incompleto. No se cambian claves de catálogo ni búsquedas por el aspecto
del texto. Android analiza las fuentes generadas antes del commit; FontLoader
las carga antes de publicar el conjunto observable. Se cargan una sola vez por
engine porque solo se acepta un hash ROM y la versión del generador es fija.
Una modificación futura del algoritmo requiere subir versión/alias del conjunto.

## Diseño claro y oscuro

El juego no ofrece el selector Android claro/oscuro. Ambas variantes comparten
materiales originales y lenguaje de File Select/pausa:

- Claro: cielo Clouds, piedra gris, bisel blanco/oscuro, tinta oscura, rojo y oro.
- Oscuro: cielo BBH, piedra oscura, panel de pausa, tinta clara y selección oro.
- Radio cero, relieve definido y marcos cuadrados; se retiran crema, azul pastel,
  superficies redondeadas y el cielo procedural para Mario con recursos listos.
- Piedra de panel a **opacidad 1**. Se remapea luminancia 190–255 en claro y 24–72
  en oscuro: conserva el relieve de ROM y garantiza lectura. Marcos de botones
  muestran piedra sin remap. No se usa un overlay casi invisible como en v1.
- `gameDecoration` centraliza materiales en todas las superficies rectangulares
  neutras de las pantallas y componentes. Gradientes de fotografías, círculos,
  transparencia y rellenos semánticos conservan su contrato de contraste.
- Controles Material tienen marco de piedra, tipografía de menú y forma cuadrada;
  el fondo de una acción mantiene color/foreground real, incluidas acciones de
  error/cancelación. Inputs, sheets y diálogos siguen los mismos roles.
- `MarioGameIcon` cambia símbolos que tienen equivalente ROM. Búsqueda, errores,
  accesibilidad y marcas sin equivalente original conservan icono comprensible.
- `MarioGameTitle` dibuja glifos HUD/menu a color, escala de texto y etiquetas
  accesibles. Body/caption usa fuente de diálogo mediante ThemeData/fachada.
- Drawer, Home, Top downloads, catálogo, favoritos, Biblioteca, detalle, VIP,
  DynOS, Touch Controls, OMM, Render96, Popular, enlaces y avisos comparten política.
  Las imágenes de los mods siguen siendo contenido del catálogo.

El diseño se inspira en la estructura del menú original y la adapta al teléfono;
no se afirma una reproducción 3D 1:1 de una pantalla 320×240. Modelos, música y
sonido original no forman parte de esta implementación visual. El overlay sigue
con su diseño fijo y no lee ni necesita el conjunto.

## Almacenamiento, migración y confirmación

`MarioAssetsPlugin`, registrado solo en MainActivity, conserva canal
`sm64cdpy/mario_assets`: read/import/cancel/remove. Un executor serial hace lectura,
MIO0, generación, fsync y verificación de imágenes/fuentes fuera del hilo UI.
Solo el commit pequeño del pointer se serializa con cancelación en main.

Se escribe `noBackupFilesDir/mario_theme_v2/<UUID>/`; SharedPreferences `mario_theme`
guarda `generation`. Cada importación crea rutas inmutables nuevas. Commit false
restaura también la copia en memoria de preferencias. Cancelación, engine destruido
o error no publica el directorio incompleto. Se cierra el stream al cancelar;
el Future original confirma el terminal, no el acuse de la orden cancel.

Lectura valida 151 PNG por dimensión y tres TTF por presencia/tamaño. Si hay v1,
lee sus 15 PNG desde `mario_theme_v1`, conserva apariencia y muestra que debe
reimportarse para el conjunto nuevo. No puede reconstruir fuentes/cielos sin
volver a seleccionar la ROM: v1 no retenía sus bytes. Cancelar actualización
conserva v1. Una vez v2 queda confirmado, un arranque posterior limpia generaciones
v1/inactivas; remove limpia pointer y el siguiente arranque elimina archivos.

Rotación conserva pendiente y reinstala ActivityResultListener. Navegar no corta
la operación ni el coordinador. Muerte de proceso conserva el último pointer;
el próximo arranque descarta staging. Se limita ROM a 8 MiB + un byte, cada segmento
MIO0 a 2 MiB, PNG a 512 KiB y TTF a 1 MiB. Se verifican controles, referencias,
rangos, dimensiones y checksum/fuentes; no se ejecuta código de ROM.

## Verificación de sincronización de estado

- Android escribe conjunto/pointer y read lo verifica; service/provider lo leen.
  Los PNG/fuentes confirmados son autoridad; Riverpod/ThemeData son proyección.
- AppearanceNotifier sigue siendo único escritor de tema/modo Hive; coordina
  importación antes de setTheme. Cancel/error mantiene elección anterior. Modo
  independiente; los dos engines no comparten variables ni familias por defecto.
- Cache: fuentes versionadas una vez por engine, ImageCache por ruta UUID. Una
  nueva generación cambia las claves; archivos viejos se limpian al arrancar.
- Futures: UI espera selección/importación/cancelación; FontLoader se espera.
  initialize en main mantiene unawaited intencional con errores capturados.
- Hermanos: todas las pantallas y widgets principales, diálogos de carpetas,
  biblioteca/activación, fuentes y fallback de overlay. WorkManager, identidad,
  configuración del juego y eventos de instalación no se modifican.

## Validación y matriz física

V1: Testing #192 y prueba del usuario correctos. V2: nueva validación CI pendiente.
Tests sintéticos: MIO0, rangos, RGBA/IA, relieve y conteo único; parser Java AWT y
checksum de TrueType; selección sólo tras importación confirmada, cancelación,
conservación de recursos, roles de fuentes, contraste, modos e independencia.
Fixtures no contienen ROM ni imágenes originales.

En dispositivo: reimportar desde v1; ambas escenas y tipografías; recorrer todas
las pantallas; texto grande/TalkBack; cancelar selector y extracción; ROM inválida;
rotar/navegar/reabrir; falta de espacio; retirar recursos y volver a elegir Mario.
Revisar especialmente orientación del font de diálogo y recorte de skybox en
portrait/landscape. Rendering correcto con datos reales requiere esa prueba.

Fuentes Android/Flutter: [SAF](https://developer.android.com/training/data-storage/shared/documents-files),
[exclusión de backup](https://developer.android.com/identity/data/autobackup),
[ButtonStyle.backgroundBuilder](https://api.flutter.dev/flutter/material/ButtonStyle/backgroundBuilder.html).

## Revisión de tipografía desde capturas — 14 octubre 2026

Testing #198 completó análisis, 85 pruebas Flutter, APK arm64 y pruebas nativas.
Las capturas locales mostraron encabezados del drawer divididos por letras: el
separador ocupaba la mitad de la fila y cada sprite era un punto de salto. Mario
ahora usa la fuente de menú para encabezados de sección, 13.5 puntos y todo el
ancho disponible; los títulos destacados conservan los recursos HUD. El texto
de diálogo compartido tiene mínimo 14 puntos, peso normal y tracking cero.
Ajustes distingue opciones de 16 puntos y descripciones de 14; las rutas usan
Roboto de 14 para lectura precisa. Retro Manga conserva su escala. No cambia
la importación, el formato v2, preferencias, workers ni el engine del overlay.
Las capturas no se incluyen en el commit. Validación visual física pendiente
para el nuevo ajuste, incluidos claro/oscuro y escala de texto aumentada.

Validación del ajuste: [Testing #199](https://github.com/retired64/sm64cdpy.releases/actions/runs/38634094017), completado correctamente: formato Dart, análisis, pruebas Flutter, APK arm64 y pruebas nativas. Los commits posteriores sincronizan formato y documentación; no cambian el comportamiento probado.
