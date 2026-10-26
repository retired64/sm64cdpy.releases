# Plan histórico — Integración de la pantalla Jugador de SM64CoopDX

> Guía de planificación conservada desde APOYO.md. Contrastar propuestas con
> el código actual y la documentación vigente antes de implementar.

## Propósito de este documento

Este documento es una guía operativa para implementar en SM64CDPY una pantalla
**Jugador / Player** compatible con la configuración real de SM64CoopDX. Está
dirigido a DeepSeek u otro agente que vaya a realizar la implementación.

No debes completar huecos inventando contratos, nombres de métodos, rutas o
formatos. Antes de escribir código, verifica cada comportamiento en los archivos
indicados. Cuando este documento use palabras como **propuesto**, **futuro** o
**candidato**, significa que esa pieza todavía no existe y su nombre puede cambiar
después de revisar la arquitectura actual.

El objetivo de producto es permitir que el usuario:

- edite su nombre de jugador;
- cambie los ocho grupos de color de Mario;
- vea una previsualización cómoda y fluida;
- cargue paletas compatibles con SM64CoopDX;
- cree y administre paletas personales;
- aplique el perfil a `user/sm64config.txt` sin perder otras opciones;
- use la carpeta del juego y la ROM que SM64CDPY ya tiene conectadas, sin pedir
  otra selección de carpeta o archivo.

No incluyas todavía mapeo de controles, Bluetooth ni selección de otros modelos.
Conserva `coop_player_model` tal como esté almacenado. La primera entrega se
centra en el perfil y la paleta de Mario.

## Reglas obligatorias antes de modificar

1. Lee completo `AGENTS.md` desde la raíz del repositorio.
2. Ejecuta `git status --short` y conserva cualquier cambio ajeno.
3. Comprueba la rama actual. No hagas merge, tag, release ni push salvo petición
   explícita del usuario.
4. Lee la documentación vigente:
   - `docs/ARCHITECTURE.md`
   - `docs/PROJECT_STATUS.md`
   - `docs/CI_CD.md`
   - `docs/SM64CDPY-v1.7.0-TASK-CHECKLIST.md`
5. Busca todos los lectores y escritores de la carpeta del juego,
   `sm64config.txt`, recursos Mario, preferencias, MethodChannels y providers.
6. Verifica los nombres y firmas actuales antes de reutilizarlos. No copies los
   nombres propuestos en esta guía como si ya fueran API existente.
7. Completa el flujo vertical: Android/SAF, canal, servicio Dart, dominio,
   provider, pantalla, navegación, temas, localización, pruebas y documentación.

Comandos iniciales recomendados:

```bash
git status --short
git branch --show-current
rg -n "sm64config|GameFolder|MarioRom|MarioTheme|MethodChannel|palette|Player" \
  lib android sm64coopdx/src sm64coopdx/palettes
rg -n "GameModActivationStore|InstallationSafAccessCoordinator|AtomicFile" android lib
rg -n "RetroTheme|AppThemeDesign|themeDesignProvider" lib
```

## Fuentes de verdad que debes investigar

Hay dos proyectos dentro del árbol de trabajo con finalidades distintas:

- La aplicación Flutter/Android que se modificará vive en `lib/` y `android/`.
- `sm64coopdx/` es código fuente de referencia del juego. Úsalo para conocer el
  contrato exacto, pero no lo conviertas en dependencia de compilación de la app
  ni publiques cambios accidentales dentro de esa carpeta.

Si el comportamiento de esta guía difiere del código fuente del juego, manda el
código fuente verificado. Documenta la diferencia antes de implementar.

### Código fuente del juego: perfil y paletas

Investiga estos archivos en este orden:

1. `sm64coopdx/src/pc/djui/djui_panel_player.c`
   - Flujo real del menú Player.
   - Selección de parte y preset.
   - Conversión entre canales RGB y hexadecimal.
   - Cuándo se actualiza `configPlayerPalette`.
   - Cómo se activa `CUTSCENE_PALETTE_EDITOR`.
   - Cómo se valida el nombre antes de presentarlo.

2. `sm64coopdx/src/game/player_palette.h`
   - Enum y orden exacto de las partes.
   - Estructuras `PlayerPalette` y `PresetPalette`.
   - Límite `MAX_PRESET_PALETTES`.
   - Directorio definido por `PALETTES_DIRECTORY`.

3. `sm64coopdx/src/game/player_palette.c`
   - Colores predeterminados.
   - Lectura de `.ini`.
   - Orden y nombre exacto de las 24 claves.
   - Base numérica aceptada por el parser.
   - Formato exacto producido por el exportador.
   - Reglas de nombre, sobrescritura y eliminación.
   - Diferencia entre paletas del recurso del juego y paletas escribibles.

4. `sm64coopdx/src/pc/configfile.c` y
   `sm64coopdx/src/pc/configfile.h`
   - Registro de `coop_player_name`, `coop_player_model` y las ocho claves
     `coop_player_palette_*`.
   - Parser y serializador de `CONFIG_TYPE_COLOR`.
   - Tamaño `MAX_CONFIG_STRING`.
   - Valores por defecto y normalización al cargar.
   - Cuándo el juego vuelve a guardar todo el archivo.

5. Busca la implementación de `network_player_name_valid` antes de definir la
   validación de Flutter o Kotlin. No reduzcas sus reglas a una expresión regular
   supuesta.

6. `sm64coopdx/src/game/mario_misc.c`
   - Cómo cada grupo RGB se transforma en luces ambientales y difusas.
   - Cómo influye la dirección de iluminación sobre el color visible.

7. `sm64coopdx/src/game/camera.c` y
   `sm64coopdx/src/game/mario_actions_stationary.c`
   - Pose y cámara usadas por el editor del juego.
   - Usa estos archivos como referencia visual. No intentes ejecutar esa cámara
     dentro de Flutter.

8. `sm64coopdx/src/pc/platform.c`, `sm64coopdx/src/pc/pc_main.c` y las
   implementaciones Android de `sys_user_path()`.
   - Confirma cómo Android obtiene la carpeta `user`.
   - Confirma dónde `fs_get_write_path(PALETTES_DIRECTORY)` termina realmente.

9. `sm64coopdx/palettes/*.ini`
   - Fixtures reales para probar el parser.
   - No supongas que seleccionar un `.ini` guarda el nombre del preset como
     configuración activa: compruébalo en el juego.

### Código fuente del juego: apariencia de Mario y ROM

Antes de prometer una vista previa fiel, investiga:

- `sm64coopdx/actors/mario/model.inc.c`
- archivos incluidos por el modelo dentro de `sm64coopdx/actors/mario/`;
- display lists, vértices, texturas y jerarquía usada por la pose;
- el segmento y offsets de ROM utilizados por esos recursos;
- descompresión MIO0 existente en el proyecto;
- tipos gráficos y comandos necesarios para una única pose estática.

No afirmes que basta con teñir una imagen completa. La gorra, camisa, overol,
piel, cabello, zapatos, guantes y emblema necesitan regiones independientes.
Tampoco copies un render del juego como un asset empacado de la aplicación. La
previsualización debe derivarse de la ROM proporcionada por el usuario y
guardarse en almacenamiento privado generado.

## Arquitectura existente de SM64CDPY que debes respetar

### Carpeta unificada del juego y SAF

Lee:

- `android/app/src/main/kotlin/mods/sm64cdpy/GameFolderStore.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/GameFolderLayout.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/GameFolderAccess.kt`
- `lib/services/game_folder_service.dart`
- `lib/presentation/providers/game_folder_provider.dart`
- `lib/presentation/widgets/game_folder_card.dart`
- `lib/presentation/widgets/game_setup_widgets.dart`

La pantalla Jugador debe usar la conexión existente. No abras un selector nuevo
para `user`, `sm64config.txt`, `palettes` o la ROM. Si falta acceso, usa el flujo
guiado de conexión ya presente.

Verifica cómo `GameFolderStore` diferencia la raíz del juego y `user`. No
construyas rutas de `/sdcard/` manualmente: todo acceso debe resolverse mediante
los `DocumentFile`/URI persistidos y los helpers actuales.

### Editor actual de `sm64config.txt`

Lee con especial atención:

- `android/app/src/main/kotlin/mods/sm64cdpy/GameModActivationStore.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/GameModConfig.kt`
- `android/app/src/test/kotlin/mods/sm64cdpy/GameModConfigTest.kt`
- `lib/services/game_mod_activation.dart`
- `lib/presentation/providers/game_mod_activation_provider.dart`
- `lib/presentation/widgets/game_mod_activation_panel.dart`

La activación de mods y la futura pantalla Jugador escriben el mismo archivo.
No implementes un segundo escritor aislado. Primero extrae o crea una transacción
compartida para el documento completo, reutilizable por ambos flujos.

Esa capa compartida debe:

- aplicar el mismo límite de tamaño y validación UTF-8;
- preservar líneas desconocidas, comentarios, orden y finales de línea;
- adquirir el bloqueo SAF compartido que ya usa la instalación;
- comprobar que no haya una operación incompatible en curso;
- releer antes de escribir y detectar cambios externos;
- escribir de forma segura, hacer `flush`/sincronización cuando sea posible y
  verificar mediante una lectura posterior;
- mantener una estrategia de respaldo común;
- restaurar sin borrar modificaciones más recientes de otra función.

No permitas un respaldo independiente para mods y otro para Player. Restaurar
uno podría deshacer los cambios del otro. Migra con cuidado cualquier clave de
respaldo existente y conserva compatibilidad razonable.

### Canal Android y registro de plugins

Inspecciona:

- `android/app/src/main/kotlin/mods/sm64cdpy/MainActivity.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/MarioAssetsPlugin.kt`
- `lib/services/mod_installer.dart`
- `lib/services/mario_theme_assets_service.dart`

Decide después de leerlos si el perfil pertenece al canal existente de
instalación o a un canal enfocado. Evita un MethodChannel por widget. Mantén el
contrato tipado en Dart y valida todos los mapas recibidos de plataforma.

Los siguientes nombres son ideas de contrato, no APIs existentes:

```text
getPlayerProfile
applyPlayerProfile
listPlayerPalettes
savePlayerPalette
deletePlayerPalette
restorePlayerProfile
preparePlayerPreview
```

Si escoges otros nombres, mantenlos coherentes entre Kotlin, Dart y pruebas.
Cada error nativo debe convertirse en un código estable y un mensaje accionable;
no presentes `PlatformException(... null)` al usuario.

### Sistema existente de ROM y recursos Mario

Lee:

- `android/app/src/main/kotlin/mods/sm64cdpy/MarioAssetsPlugin.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/MarioRomDecoder.kt`
- `android/app/src/main/kotlin/mods/sm64cdpy/MarioPixelFont.kt`
- `android/app/src/test/kotlin/mods/sm64cdpy/MarioRomDecoderTest.kt`
- `android/app/src/test/kotlin/mods/sm64cdpy/MarioPixelFontTest.kt`
- `lib/domain/entities/mario_theme_assets.dart`
- `lib/services/mario_theme_assets_service.dart`
- `lib/presentation/providers/mario_theme_assets_provider.dart`
- `lib/presentation/widgets/mario_assets_coordinator.dart`
- `lib/presentation/widgets/mario_rom_assets_panel.dart`
- `test/presentation/mario_theme_assets_provider_test.dart`
- `test/presentation/mario_rom_fixture.dart`

Extiende este sistema; no crees una segunda selección o una segunda copia de la
ROM. Conserva sus garantías:

- validación exacta de ROM compatible;
- generación versionada;
- ejecución pesada fuera del hilo principal;
- cancelación;
- publicación atómica de una generación completa;
- salida dentro del almacenamiento privado de la aplicación;
- Flutter recibe rutas a recursos generados, nunca bytes de ROM.

Antes de modificar el formato de salida, verifica qué campos consume cada lector
y cómo se invalida la generación actual.

### Navegación y temas

Lee:

- `lib/core/router/app_router.dart`
- `lib/presentation/widgets/app_shell.dart`
- `lib/presentation/widgets/app_drawer.dart`
- `lib/core/theme/retro_theme.dart`
- `lib/core/theme/app_theme_design.dart`
- `lib/core/theme/app_theme_catalog.dart`
- `lib/core/theme/themes/retro_manga_theme.dart`
- `lib/core/theme/themes/mario64_theme.dart`
- `lib/core/theme/themes/sm64_intro_theme.dart`
- `lib/presentation/providers/theme_provider.dart`
- pruebas en `test/core/theme/` y `test/presentation/*theme*`.

La ruta recomendada es `/player` dentro del `ShellRoute`, con acceso desde el
drawer. Confirma primero la estructura vigente del router. Jugador es una función
principal y no debe ocultarse como una preferencia de Ajustes.

No dibujes una única tarjeta Material genérica y cambies solamente colores. Usa
los tokens y componentes existentes de `RetroTheme`. Investiga pantallas y
widgets hermanos para reproducir bordes, fondos, elevación, patrones, títulos,
botones, transiciones y tipografía de cada diseño.

## Contrato confirmado que debe conservarse

Verifica nuevamente estos datos antes de codificar, pero tómalos como puntos que
la investigación previa ya localizó:

- El perfil activo vive en `user/sm64config.txt`.
- Claves del perfil:
  - `coop_player_name`
  - `coop_player_model`
  - `coop_player_palette_pants`
  - `coop_player_palette_shirt`
  - `coop_player_palette_gloves`
  - `coop_player_palette_shoes`
  - `coop_player_palette_hair`
  - `coop_player_palette_skin`
  - `coop_player_palette_cap`
  - `coop_player_palette_emblem`
- Orden lógico de partes: `PANTS`, `SHIRT`, `GLOVES`, `SHOES`, `HAIR`, `SKIN`,
  `CAP`, `EMBLEM`.
- Cada color de configuración son tres componentes hexadecimales de dos dígitos,
  separados por espacios y sin `#`.
- El perfil Mario predeterminado localizado actualmente es:

```text
PANTS  00 00 ff
SHIRT  ff 00 00
GLOVES ff ff ff
SHOES  72 1c 0e
HAIR   73 06 00
SKIN   fe c1 79
CAP    ff 00 00
EMBLEM ff 00 00
```

- Los presets usan archivos `.ini` con sección `[PALETTE]` y 24 componentes,
  por ejemplo `PANTS_R`, `PANTS_G`, `PANTS_B`.
- La selección de preset copia colores al perfil. El nombre del preset no es la
  fuente persistente de la paleta activa.
- Las paletas personales se resuelven desde el directorio escribible `palettes`
  del juego. Confirma su ruta Android exacta mediante `fs_get_write_path` y el
  layout conectado antes de implementar.
- El juego contempla un máximo de 128 presets.
- El nombre usa el límite de `MAX_CONFIG_STRING`; confirma en la revisión actual
  su tamaño y la semántica exacta de bytes UTF-8.

No sustituyas el parser real del juego por suposiciones. Crea fixtures a partir
de los `.ini` existentes y cubre valores decimales y cualquier otra base que el
`strtol` real permita.

## Diseño de dominio recomendado

Los nombres siguientes son propuestos. Adáptalos a las convenciones reales:

```text
PlayerProfile
  name
  model
  palette
  sourceRevision

PlayerPalette
  pants, shirt, gloves, shoes, hair, skin, cap, emblem

PlayerPalettePreset
  stableId
  displayName
  source: builtIn | user
  palette
  writable

PlayerPreviewAssets
  generation
  romDigest
  views
  masksByPart
```

Usa tipos inmutables. No propagues mapas sin validar por toda la interfaz. Un
color debe tener canales acotados a `0..255` y conversión única entre RGB,
`#RRGGBB`, configuración del juego y `.ini`.

Para IDs de presets, distingue el origen aunque dos archivos compartan nombre,
por ejemplo mediante un identificador conceptual `builtin:<nombre>` frente a
`user:<document-id>`. No uses el título visible como identidad.

## Fuente de verdad y estado de la pantalla

Separa obligatoriamente:

1. **Perfil confirmado:** última lectura verificada de `sm64config.txt`.
2. **Borrador local:** nombre y colores que el usuario está editando.
3. **Catálogo de presets:** proyección de paletas del juego y del usuario.
4. **Recursos de vista previa:** generación privada derivada de la ROM.

`sm64config.txt` es la fuente de verdad del perfil activo. Los `.ini` son fuente
de verdad de presets reutilizables. El provider es una proyección y el borrador
no se considera persistido.

Editar un slider debe cambiar únicamente el borrador y la composición visual.
No invoques plataforma ni escribas SAF en cada movimiento. **Aplicar al juego**
debe enviar nombre y ocho colores en una sola transacción verificada.

Estados mínimos del provider:

```text
initial/loading
needsGameFolder
missingConfig
ready(clean | dirty)
saving
conflict
saved
permissionRevoked
failure(retryable | terminal)
```

La preparación de preview tiene estado independiente:

```text
notPrepared -> preparing(progress) -> ready
                              \----> unsupportedRom | failed | cancelled
```

El fallo de preview no debe impedir editar ni aplicar colores.

## Conflictos y juego abierto

SM64CoopDX puede volver a guardar la configuración cuando está abierto o al
cerrarse. No prometas detectar de forma fiable el proceso de otra aplicación.

La experiencia debe indicar que se cierre el juego antes de aplicar y que los
cambios se verán al volver a abrirlo. Inmediatamente antes de escribir:

1. relee el documento;
2. compara con la revisión que originó el borrador;
3. si cambió, no sobrescribas silenciosamente;
4. permite recargar o conservar el borrador;
5. si el usuario conserva el borrador, aplica solo las claves Player sobre la
   versión más reciente;
6. vuelve a leer y confirma el resultado.

Al regresar del background, refresca automáticamente si el borrador está limpio.
Si está sucio y el archivo cambió, conserva el borrador y presenta el conflicto.

## Diseño de la pantalla

### Jerarquía general

```text
AppBar: Jugador
┌──────────────────────────────────┐
│ Vista previa de Mario            │
│ frontal / tres cuartos / espalda │
└──────────────────────────────────┘
Nombre del jugador
Presets: Original | juego | usuario | Personalizada
Cuadrícula de 8 partes
Editor de la parte seleccionada
Restablecer   Guardar paleta   Aplicar al juego
```

En teléfonos, usa una columna desplazable con una barra de acciones accesible.
En ancho suficiente, considera preview a un lado y controles al otro. Comprueba
teclado abierto, navegación atrás, orientación horizontal y texto ampliado.

### Vista previa

Primera versión recomendable:

- pose estática neutral fiel al juego;
- tres vistas pregeneradas o, si el alcance inicial lo exige, una vista de tres
  cuartos bien terminada;
- fondo del tema, sin teñir el modelo por modo claro/oscuro;
- cambio de color instantáneo mediante capas/máscaras locales;
- estado guiado para preparar assets de la ROM;
- controles accesibles para cambiar ángulo.

No inicies con un visor 3D interactivo completo. Un renderizador limitado a una
pose fija reduce riesgo y puede producir resultados fluidos. No uses una
silueta genérica como resultado final si el objetivo aprobado es fidelidad al
juego.

### Editor

Cada parte debe mostrar etiqueta localizada, muestra, hexadecimal y selección
visible. El editor seleccionado debe ofrecer:

- muestra grande;
- entrada `#RRGGBB` con validación;
- canales R, G y B de `0..255`;
- restaurar solamente esa parte;
- actualización inmediata del borrador y preview.

El color no puede ser la única señal de estado. Añade etiqueta, selección,
semántica para TalkBack y objetivos táctiles de al menos 48 dp cuando sea
posible.

### Presets

- Seleccionar un preset modifica el borrador, no escribe todavía.
- **Guardar como paleta** crea un `.ini` personal.
- Sobrescribir requiere confirmación explícita.
- Solo las paletas personales se pueden eliminar.
- Las paletas integradas se muestran como solo lectura.
- Cuando el borrador no coincida con ninguna, presenta “Personalizada”.
- No uses coincidencia por nombre; compara los 24 canales.

### Navegación con cambios pendientes

Al intentar salir con un borrador sucio, ofrece acciones claras para continuar,
descartar o aplicar. No pierdas cambios por un rebuild, rotación o apertura de
un diálogo. Tras muerte del proceso no persistas silenciosamente un borrador
como si estuviera aplicado; si decides recuperar un borrador, identifícalo
claramente como pendiente.

## Integración auténtica con cada tema

La pantalla comparte dominio y comportamiento, pero no debe sentirse idéntica
con tres paletas de color diferentes.

### Retro Manga

Investiga los componentes que ya consumen `showHalftone`, tramas, contornos,
etiquetas y composición manga dentro de `retro_theme.dart` y las pantallas
actuales. Usa:

- encabezados y paneles manga existentes;
- contraste fuerte y separación clara de controles;
- selección de parte con el lenguaje visual del tema;
- animaciones cortas coherentes con otros selectores.

### Mario 64

Investiga cómo `mario64_theme.dart`, el coordinador de assets y las pantallas
actuales usan los recursos generados desde la ROM. Usa:

- fuente Mario únicamente donde la jerarquía actual la permita;
- paneles, texturas, relieves y colores ya definidos por el tema;
- preview como elemento principal;
- controles legibles: no uses la fuente de títulos para texto pequeño, valores
  RGB o descripciones.

### SM64 Intro

Investiga `sm64_intro_theme.dart` y los widgets que ya implementan su lenguaje
visual. El selector de presets y las ocho partes pueden inspirarse en el selector
de ranuras, pero deben seguir siendo controles accesibles. Mantén colores,
sombras, marcos y estados de selección coherentes con ese tema.

### Reglas comunes

- Consume `RetroTheme.of(context)` y componentes reutilizables existentes.
- No bifurques lógica de archivos o providers por tema.
- No alteres el color real de Mario al cambiar brillo del tema.
- Prueba claro y oscuro para cada diseño.
- Evita tamaños de título que provoquen saltos de línea en drawer o AppBar.

## Plan para la vista previa derivada de la ROM

Antes de implementarla, escribe un pequeño documento técnico con los offsets,
formatos y comandos realmente necesarios, citando archivos y líneas del código
fuente local. No aceptes una propuesta basada únicamente en memoria.

Arquitectura recomendada:

1. El plugin existente localiza y valida la ROM mediante la carpeta conectada.
2. Un worker interno o ejecutor en background decodifica solo los recursos de
   Mario necesarios.
3. Un renderizador limitado produce por vista:
   - una base con elementos que no cambian;
   - una máscara en escala de grises/alfa para cada parte configurable;
   - metadatos de tamaño, vista, versión y digest de ROM.
4. Se escribe una generación temporal completa.
5. Solo después de validarla se publica atómicamente como generación activa.
6. Flutter carga la base y máscaras y aplica tintes localmente.

Investiga cómo aproximar la iluminación del juego a partir de
`mario_misc.c`. Una máscara plana puede producir colores incorrectos si elimina
todo sombreado; conserva luminancia y alfa para que el tinte mantenga volumen.

El manifiesto debe permitir invalidar por:

- versión del decodificador/renderizador;
- digest de ROM;
- dimensiones o formato de salida;
- lista incompleta o corrupta de archivos.

No guardes la ROM, segmentos crudos innecesarios ni recursos sin versión en
almacenamiento accesible a otras aplicaciones.

## Rendimiento esperado

- Los sliders y el campo hexadecimal deben actualizar la preview en el mismo
  frame o en el siguiente, sin MethodChannel.
- El perfil se lee una vez al entrar y se refresca por eventos concretos.
- El catálogo de paletas se escanea una vez; se invalida al crear, sobrescribir,
  eliminar, cambiar carpeta o refrescar manualmente.
- La vista previa generada se reutiliza entre aperturas.
- Ningún análisis de ROM, recorrido SAF o parseo de archivos se ejecuta dentro
  de `build()`.
- Agrupa nombre y ocho colores en una sola escritura.
- Deduplica refresh simultáneos siguiendo patrones de los providers actuales.
- Todo Future disparado con `unawaited` debe capturar internamente sus errores.

## Localización

Toda cadena visible debe existir en:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_es_419.arb`
- `lib/l10n/app_pt.arb`
- `lib/l10n/app_pt_BR.arb`

Inglés es la referencia semántica. Ejecuta `flutter gen-l10n`; no edites los
archivos Dart generados manualmente. Localiza nombres de partes, estados de ROM,
conflictos, validaciones, acciones y mensajes de recuperación.

## Implementación por fases

No mezcles todas las fases en un único cambio imposible de revisar.

### Fase 0 — Investigación verificable

- Registra rutas, símbolos y formatos exactos.
- Dibuja el flujo actual de `sm64config.txt` y su respaldo.
- Identifica todos los lectores/escritores con `rg`.
- Confirma la ruta real de paletas en Android.
- Define el contrato de errores y revisión externa.
- Define qué parte de la ROM necesita el preview.

Salida esperada: notas técnicas sin cambios funcionales.

### Fase 1 — Documento de configuración compartido

- Extrae la lectura/escritura segura y sin pérdida.
- Migra `GameModActivationStore` a esa transacción.
- Conserva comportamiento y rendimiento de activación de mods.
- Centraliza backup, compare-and-swap y verificación.
- Añade pruebas de regresión antes de incorporar Player.

No continúes si activar/desactivar mods puede perder opciones desconocidas.

### Fase 2 — Perfil y presets nativos

- Implementa parser/serializador del perfil.
- Implementa lectura y aplicación atómica.
- Implementa catálogo de paletas.
- Implementa crear, confirmar sobrescritura y eliminar paletas personales.
- Agrega errores estables para carpeta, permiso, conflicto, formato y escritura.

### Fase 3 — Dominio, provider y pantalla funcional

- Crea entidades tipadas.
- Crea servicio/repository Dart.
- Crea provider con confirmado, borrador y conflictos.
- Agrega `/player` y entrada de drawer.
- Implementa edición completa con muestras de color aunque todavía no exista el
  render final.
- Completa localización y accesibilidad.

### Fase 4 — Preview auténtico de ROM

- Extiende el generador Mario existente.
- Implementa decodificación y render limitado.
- Produce base y máscaras versionadas.
- Integra progreso, cancelación, reintento y caché.
- Valida que los ocho colores se distingan correctamente.

### Fase 5 — Diseño nativo por tema y endurecimiento

- Adapta composición a los tres diseños.
- Prueba claro/oscuro, texto ampliado y TalkBack.
- Revisa rotación, background y muerte del proceso.
- Actualiza changelog y documentación vigente.
- Ejecuta validaciones completas.

## Pruebas mínimas

### Unidad Android

- Perfil válido y valores por defecto.
- Colores hexadecimales válidos, inválidos, incompletos y fuera de rango.
- Nombre vacío, límite exacto, UTF-8 multibyte y reglas reales del juego.
- Config con LF, CRLF, comentarios y claves desconocidas.
- Claves duplicadas según la semántica real del parser del juego.
- Archivo ausente, vacío, truncado, inválido y demasiado grande.
- Compare-and-swap ante modificación externa.
- Escritura verificada y restauración.
- Transacciones alternadas: mods -> Player -> mods.
- Presets del repositorio como fixtures.
- Preset decimal y cualquier base aceptada realmente por el juego.
- Duplicados entre built-in y usuario.
- Límite de presets, archivo grande y nombre con traversal.

### Unidad/widget Flutter

- Carga inicial y carpeta no conectada.
- Borrador limpio/sucio.
- Cambio instantáneo de las ocho partes.
- Conversión RGB/hex.
- Selección de preset sin escritura inmediata.
- Aplicación confirmada, error y conflicto.
- Navegación con cambios pendientes.
- Preview ausente, preparando, listo, incompatible y fallido.
- Todos los temas y ambos modos de brillo.
- Texto grande sin overflow.
- Semántica de partes, sliders y acciones.

### Matriz física Android

- Instalación limpia.
- Carpeta válida y permiso SAF revocado.
- Config inexistente hasta abrir el juego una vez.
- Juego cerrado y juego abierto durante la edición.
- El juego cambia el archivo mientras la app está en background.
- Aplicar perfil y después activar/desactivar mods.
- Activar mods y después aplicar perfil.
- Crear, sobrescribir y eliminar un preset.
- Rotar, minimizar, cerrar y reabrir.
- Cancelar preparación de preview.
- ROM admitida, ausente e incompatible.
- Reinicio del proceso durante una generación temporal.

## Validación técnica

Después de cada fase ejecuta lo aplicable:

```bash
dart format <archivos Dart modificados>
flutter gen-l10n                    # cuando cambien ARB
flutter analyze lib
flutter test
android/gradlew -p android :app:compileDebugKotlin
git diff --check
```

Si Termux no tiene Flutter/Dart/Java disponibles, ejecuta al menos las
validaciones posibles, deja `git diff --check` limpio y documenta exactamente
qué deberá comprobar GitHub Actions. No afirmes que compila si no se ejecutó la
compilación.

## Errores de diseño que debes evitar

- Pedir nuevamente la ROM o la carpeta `user`.
- Construir rutas absolutas `/sdcard/...`.
- Reescribir por completo `sm64config.txt` con solo las claves conocidas.
- Mantener backups incompatibles entre mods y Player.
- Escribir en cada cambio de slider.
- Marcar como aplicado antes de la confirmación nativa.
- Confundir guardar un `.ini` con activar esa paleta.
- Eliminar paletas integradas.
- Usar el nombre visible como identidad estable.
- Realizar acceso SAF o trabajo de ROM en el hilo UI.
- Bloquear la edición completa porque falle el preview.
- Usar una imagen de Mario empaquetada como sustituto permanente de la ROM.
- Aplicar filtros del tema que alteren los colores reales del perfil.
- Duplicar lógica para cada tema.
- Añadir lógica de persistencia dentro de tarjetas visuales.
- Conectar el estado al overlay mediante variables estáticas.

## Criterios de aceptación

La integración se considera completa únicamente si:

- una sola selección de carpeta abastece mods, DynOS, configuración, paletas y
  búsqueda de ROM;
- la pantalla funciona aunque no se pueda generar preview;
- los cambios visuales son instantáneos y las escrituras son transaccionales;
- el juego interpreta exactamente los colores y nombre escritos;
- las opciones ajenas de `sm64config.txt` permanecen intactas;
- alternar entre gestión de mods y Player no revierte cambios;
- un cambio externo genera conflicto, no pérdida silenciosa;
- las paletas creadas son legibles por SM64CoopDX;
- la vista previa procede de la ROM verificada del usuario y usa caché privado;
- los tres temas ofrecen una composición propia y coherente;
- todas las cadenas están localizadas;
- se cubrieron ciclo de vida, permisos, errores y recuperación;
- las pruebas y análisis aplicables terminan correctamente.

## Formato requerido para el informe final de DeepSeek

El informe debe explicar:

1. qué comportamiento implementó;
2. qué contratos confirmó directamente en SM64CoopDX;
3. qué archivos cambió y por qué;
4. cómo preservó `sm64config.txt` y los respaldos;
5. cómo funciona la caché de preview y qué la invalida;
6. qué validaciones ejecutó y sus resultados;
7. qué pruebas físicas quedan pendientes;
8. riesgos o limitaciones reales, sin ocultarlos.

También debe incluir una sección titulada exactamente:

## Verificación de sincronización de estado

En ella debe responder:

- quién escribe y quién lee cada dato;
- cuál es la fuente de verdad;
- si mods, Player y carpeta del juego quedaron sincronizados;
- qué caches se añadieron y quién los invalida;
- qué Futures no se esperan intencionalmente y cómo capturan errores;
- qué implementaciones hermanas se revisaron;
- cómo se comporta ante background, reapertura, rotación y muerte del proceso.
