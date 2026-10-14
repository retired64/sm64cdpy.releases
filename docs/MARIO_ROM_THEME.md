# Mario 64: menús y recursos locales de la ROM

Implementación en `custom-themes`, para Android. No modifica la ROM ni los
archivos del juego. Retro Manga y el engine del overlay conservan sus diseños.

## Plan y alcance implementado

1. Materiales: bordes más cuadrados (8 dp), bisel, sombra definida y profundidad
   suave en las superficies compartidas. La piedra importada se repite con baja
   opacidad para conservar legibilidad; nunca sustituye el color de contraste.
2. Composición: Home/catálogos conservan cielo; Biblioteca y Ajustes usan un
   fondo de menú. Catálogo, fichas de Biblioteca, paneles y diálogos que emplean
   `surfaceDecoration` comparten el mismo tratamiento.
3. Selección: opciones de Ajustes y ruta activa del drawer muestran la mano
   original cuando está importada. Biblioteca utiliza sus dos estados; los
   encabezados usan la estrella y el contador de Biblioteca usa dígitos HUD.
4. Movimiento: entrada con profundidad en Mario; las transiciones de navegación
   se omiten con la preferencia de reducir animaciones. Se mantienen las
   animaciones de expansión de Ajustes y la respuesta de presión existente.
5. Recursos opcionales: importación de 15 PNG privados desde una ROM válida;
   sustitución completa, cancelación, retirada y restauración al diseño incluido.
6. Texto: TypefaceMario64 sigue exclusivo de títulos. Descripciones, errores y
   nombres de archivo conservan texto normal y soporte de acentos. Los iconos
   originales son decorativos; no sustituyen etiquetas accesibles ni los estados.

Sonido original y modelos/escenas 3D quedan como fases posteriores, como en la
propuesta: no se ha integrado un motor de audio N64 ni un renderizador de modelos.
No se anuncian como funciones disponibles. No hay recursos de Nintendo en git,
assets del APK, pruebas ni notas públicas descargables.

## Contrato con el código del juego

Referencias de la copia local (no se publica ni se modifica `sm64coopdx/`):

- `src/pc/rom_checker.cpp`: MD5 de la ROM vanilla US habilitada, regiones restantes
  comentadas; copia a `baserom.us.z64` y carga desde el directorio de usuario.
- `platform/app/src/main/java/org/libsdl/app/SDLActivity.java`: selección mediante
  ACTION_OPEN_DOCUMENT y copia privada antes de llamar al código nativo.
- `src/pc/rom_assets.c`: carga de segmentos y MIO0 en memoria, no exportación PNG.
- `levels/menu/leveldata.c`: segmento US `0x2a65b0`, longitud comprimida 22255:
  piedra `0x18`, piedra oscura `0x818`, mano `0x6328`, mano pulsada `0x6b28`.
  Todas son RGBA16 32×32.
- `bin/segment2.c`: segmento US `0x108a40`, longitud comprimida 48390:
  estrella `0x4800`, RGBA16 16×16; dígitos 0–9, desplazamientos `i * 512`.
- `src/pc/gfx/gfx_pc.c`: expansión RGBA5551 y transparencia de un bit.
- `src/menu/file_select.c`: crecimiento/retorno del botón y sonidos de menú;
  `src/pc/djui/djui_theme.c`: temas modernos adicionales de CoopDX. No se confunden
  los paneles DJUI con el menú original.

El importador actual acepta **únicamente ROM .z64 big-endian vanilla US de 8 MiB**
con MD5 `20b854b239203baf6c961b850a4a51a2`. No admite ROM modificada, otras regiones,
.zip ni archivos .v64/.n64 con otro orden de bytes. El nombre no es la validación;
los bytes y el hash lo son. Cambiar un offset exige un nuevo manifiesto/versionado.

## Flujo Android → Flutter

`MainActivity` registra `MarioAssetsPlugin` solo en el engine principal.
Canal `sm64cdpy/mario_assets`:

| Método | Resultado |
|---|---|
| `read` | conjunto completo verificado o mapa vacío para diseño incluido |
| `import` | selector → lectura → validación → conversión → verificación → commit; null si se cierra el selector |
| `cancel` | solicita detener; el Future original confirma el final y libera busy |
| `remove` | borra la referencia persistente y devuelve mapa vacío |

No necesita MANAGE_EXTERNAL_STORAGE ni permiso de escritura a la ROM. El usuario
concede lectura al documento elegido; no se retiene URI persistente porque los
recursos se consumen una sola vez. La selección de `user` para mods no otorga
permiso a su padre y no se utiliza para buscar la ROM automáticamente.

Un executor serial lee un máximo de 8 MiB + un byte, calcula MD5, descomprime
solo dos segmentos y genera 15 imágenes. `MarioRomDecoder` limita salida MIO0 a
2 MiB, valida controles/literales/backreferences, sus distancias y longitudes,
y comprueba los rangos de cada textura. No ejecuta código del archivo.

Cada importación escribe una generación UUID distinta en
`filesDir/mario_theme_v1/<UUID>/`. Cada PNG se sincroniza, decodifica y verifica
por dimensiones antes de cambiar la referencia `generation` en SharedPreferences
`mario_theme`. La cancelación y el commit se serializan en el hilo principal;
un fallo anterior no cambia la referencia. La ROM no se guarda ni se sube.

Las generaciones anteriores permanecen hasta el siguiente arranque del plugin;
así ImageCache no apunta a archivos eliminados durante un cambio visible. En
ese arranque se eliminan directorios de generaciones inactivas y restos de una
extracción interrumpida. Si falta una imagen o su tamaño es inválido, `read`
retira la referencia. Las imágenes Flutter tienen fallback si no se decodifican.
Retirar recursos desactiva su uso inmediato; limpia sus archivos al reabrir.

## Estado, vida útil y recuperación

`MarioThemeAssetsNotifier` vive en el ProviderScope principal, no en Ajustes.
Arranque lee el conjunto una vez; los métodos import/remove devuelven el nuevo
estado nativo. `busy` bloquea importaciones dobles y retirada simultánea. El
conjunto anterior sigue visible durante lectura/extracción. Errores y cancelación
conservan ese conjunto y liberan busy al recibir el resultado terminal.

Rotación: el plugin retira/reinstala ActivityResultListener y conserva operación.
Navegación: el notifier conserva operación y el coordinador global informa de
éxito/error. Engine destruido: marca cancelación, no entrega resultados a un canal
muerto; el siguiente engine reconcilia desde el pointer durable. Muerte del proceso:
el siguiente arranque descarta generaciones no confirmadas. No depende de Workers
de descarga/instalación ni altera su identidad, eventos, destinos o preferencias.

## Verificación de sincronización de estado

- Escritor: importer Kotlin y remove; lectores: read nativo, notifier, ThemeData,
  componentes Mario y Ajustes.
- Autoridad: pointer nativo confirmado y conjunto privado completo. Flutter es
  proyección; el tema elegido en Hive continúa independiente de estos recursos.
- Cache: archivos de generaciones inmutables e ImageCache identificados por ruta
  UUID; commit cambia las claves. Archivos inactivos se limpian al arrancar.
- Futuro no esperado: initialize en main es intencional y captura sus errores.
  Callbacks de UI esperan perform/cancel. No hay una variable para compartir
  memoria con el overlay ni nuevos escritores de preferencias del juego.
- Hermanos: catálogo general, Biblioteca, Ajustes, drawer y transiciones comunes;
  VIP/DynOS/Touch Controls/OMM/Render96/detalle siguen los roles compartidos;
  overlay mantiene su ThemeData fija sin recursos ROM.

## Validación

Tests Kotlin sintéticos: literal MIO0, copia solapada, referencia inválida, literal
truncado, límite de memoria, colores/transparencia y textura fuera de rango.
Tests Flutter: confirmación antes de sustitución, doble selección, cancelación
confirmada, error conservando conjunto, retirada y aislamiento de Retro/overlay.
No contienen una ROM ni texturas originales. Actions ejecuta gen-l10n, format,
analyze, Flutter tests y unit tests Kotlin. En Termux no hay Flutter/Dart.

Matriz física pendiente: ROM US válida, archivo corrupto/otra región/truncado,
cancelar selector y extracción, repetir, retirar, tema Retro/Mario claro/oscuro,
rotar durante selección/extracción, navegar, minimizar/reabrir, matar proceso,
espacio insuficiente y proveedor de documentos sin acceso. Revisar contraste,
texto grande, TalkBack y reducción de movimiento. Importar bytes desde un proveedor
remoto puede depender de su disponibilidad; no se afirma un tiempo fijo.
