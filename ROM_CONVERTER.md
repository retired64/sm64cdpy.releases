# Preparador de ROM — análisis y plan de integración

Fecha: 19 de octubre de 2026. Rama de análisis: `how-to-play-guide`.
Estado: **propuesta; todavía no implementada**. Este documento no cambia la
aplicación, el enlace actual, permisos, versión ni archivos del juego.

## 1. Objetivo y decisión propuesta

Incorporar **Preparar mi ROM** al capítulo 2 de Cómo jugar. El usuario elige su
propia ROM y la app identifica su formato, genera si hace falta una copia `.z64`
y comprueba que sirve para la versión Android de CoopDX estudiada.

Se recomienda implementar la transformación en Kotlin, con lectura y escritura
por bloques fuera del hilo de interfaz. Flutter presenta pasos y resultados.
No incorporar Python, NumPy, Rust, ejecutables externos ni un navegador para
esta operación. Los dos proyectos siguientes quedan como referencias técnicas;
no se clonan ni se añaden como dependencias del producto.

Alcance inicial: SM64 USA original, entrada `.n64`, `.v64` o `.z64`, salida
validada `.z64`. No es un conversor universal de juegos de Nintendo 64. No
descarga ROMs, cambia regiones, aplica parches, repara dumps ni extrae ZIP/7z.

## 2. Referencias revisadas

Los enlaces de ramas son móviles: antes de implementar, registrar el commit
exacto revisado. Los hallazgos siguientes corresponden al código consultado
en esta fecha; son revisión estática, no pruebas ejecutadas de estos programas.

### Brawl345/N64Swap

- [Repositorio y README](https://github.com/Brawl345/N64Swap).
- [Implementación n64swap.py](https://github.com/Brawl345/N64Swap/blob/master/n64swap.py).
- [Licencia Unlicense](https://github.com/Brawl345/N64Swap/blob/master/LICENSE).

Script CLI Python 3 con NumPy; repositorio archivado. `get_rom_format` reconoce
la cabecera, `swap_bytes` intercambia pares y `main` elige transformación según
formato y extensión de salida. Trabaja en bloques de 1 KiB. Para invertir grupos
de cuatro bytes utiliza `numpy.frombuffer(..., numpy.float32).byteswap()`.

Es una referencia compacta del algoritmo, no una UX Android. Tiene un TODO
explícito de comprobar entrada igual a salida: abrir la salida para escritura
puede truncar el original. Valida la extensión con minúsculas pero compara luego
la extensión original, por lo que una salida en mayúsculas puede no entrar en
ninguna conversión. No verifica identidad USA, ni publica transaccionalmente.
No trasladar estos comportamientos al preparador.

### ezntek/n64romconvert

- [Repositorio y README](https://github.com/ezntek/n64romconvert).
- [Núcleo Rust](https://github.com/ezntek/n64romconvert/blob/main/crates/n64romconvert/src/lib.rs).
- [CLI](https://github.com/ezntek/n64romconvert/blob/main/crates/n64romconvert/src/bin/n64romconvert/main.rs).
- [Licencia MIT](https://github.com/ezntek/n64romconvert/blob/main/LICENSE.md).

`RomType` representa tres formatos; `determine_format` identifica cabeceras.
El núcleo ofrece `endian_swap`, `byte_swap` y `byte_endian_swap`; el CLI elige
salida y usa `.z64` por defecto. Emplea lectores/escritores con buffer.

Precauciones del código consultado: usa `panic`/`unwrap` para errores de I/O;
no protege entrada igual a salida; verifica tamaño módulo 256 aunque los buffers
son de 512/1024 bytes. Sus bucles transforman y escriben el buffer completo sin
limitarse a `bytes_read`: lecturas parciales pueden introducir datos sobrantes.
Además, la rama CLI v64→n64 llama a `byte_swap`, mientras la biblioteca dispone
de una transformación combinada. El preparador solo necesita salida z64.
No portar estos detalles sin corregirlos y probarlos.

### Uso de estas referencias

Escribir una implementación propia, pequeña y comprobable, de las permutaciones
de bytes. Si se reutilizan partes sustanciales del proyecto MIT, conservar su
aviso de copyright y licencia en las atribuciones distribuidas. Mantener ambos
enlaces como procedencia técnica, aunque no se copie código.

## 3. Contrato real de ROM y del juego

Fuente de juego contrastada:
[rom_checker.cpp de ManIsCat2/sm64coopdx, rama android](https://github.com/ManIsCat2/sm64coopdx/blob/android/src/pc/rom_checker.cpp).
La tabla activa acepta USA mediante MD5; otras regiones están comentadas.
El juego busca `.z64` en su ruta de escritura y después en el directorio del
ejecutable. Al aceptar la ROM utiliza `baserom.us.z64` en la ruta de escritura;
no copia sobre ese destino si ya existe. No asumir que cambia automáticamente
una ROM preexistente incorrecta.

Nuestra app ya exige, en `MarioRomDecoder.kt`:

- Tamaño exacto: **8 388 608 bytes (8 MiB)**.
- MD5 canónico: `20b854b239203baf6c961b850a4a51a2`.

El hash se calcula sobre la salida normalizada z64. Se usa por compatibilidad
con el juego, no como mecanismo de autenticación criptográfica de archivos.
Cabecera correcta significa formato reconocido; tamaño correcto tampoco basta
para identificar el juego. Solo el resultado completo validado se ofrece como
compatible. No diagnosticar una región concreta únicamente por hash diferente:
también podría ser una modificación o archivo dañado.

### Transformaciones necesarias

| Contenido inicial | Formato detectado | Para obtener z64 |
|---|---|---|
| `80 37 12 40` | z64, big endian | Copiar sin alterar bytes y validar |
| `37 80 40 12` | v64, pares intercambiados | `A B C D` → `B A D C` |
| `40 12 37 80` | n64, little endian | `A B C D` → `D C B A` |
| Otra cabecera o menos de 4 bytes | Desconocido | Rechazar sin generar salida pública |

Detectar por bytes, incluso si la extensión fue renombrada. Convertir no
significa cambiar el nombre: tampoco transforma una ROM japonesa/europea o un
hack en la ROM USA requerida.

## 4. Mapa del código actual que debe reutilizarse

Todas las rutas son relativas a este repositorio y existen al redactar el plan.

| Archivo actual | Responsabilidad y adaptación prevista |
|---|---|
| `lib/presentation/screens/how_to_play_screen.dart` | Entrada en capítulo 2; cambiar acción externa por explicación y preparador local; conservar navegación y ayudas |
| `lib/presentation/widgets/play_guide_widgets.dart` | Tarjetas y composición temática de la guía; reutilizar para instrucciones breves |
| `lib/core/constants/app_constants.dart` | Contiene `romConverterUrl` de Hack64; retirarlo al migrar todos sus consumidores, no sustituirlo por otra dependencia obligatoria |
| `android/app/src/main/kotlin/mods/sm64cdpy/MarioRomDecoder.kt` | Constantes de ROM; evitar hashes/tamaños divergentes |
| `android/app/src/main/kotlin/mods/sm64cdpy/MarioAssetsPlugin.kt` | Picker, cancelación e importación existentes; `readRom` valida y `importFromUser` busca candidatos |
| `android/app/src/main/kotlin/mods/sm64cdpy/Player3DSource.kt` | ROM privada validada para Jugador; revisar efectos si cambia el archivo del juego |
| `android/app/src/main/kotlin/mods/sm64cdpy/GameFolderStore.kt` | Autoridad de carpeta autorizada; `root(context)` devuelve **user**, no la carpeta contenedora |
| `android/app/src/main/kotlin/mods/sm64cdpy/GameFolderLayout.kt` y `GameFolderAccess.kt` | Resolver rutas/permisos existentes; no construir padres desde una URI |
| `android/app/src/main/kotlin/mods/sm64cdpy/MainActivity.kt` | Registro de plugins en engine principal |
| `lib/services/mario_theme_assets_service.dart` | Canal actual `sm64cdpy/mario_assets`; no confundir preparar ROM con importar texturas/fuentes |
| `lib/presentation/providers/mario_theme_assets_provider.dart` | Estado de recursos importados; revisión hermana, sin importación automática al convertir |
| `lib/services/game_folder_service.dart` y `lib/presentation/providers/game_folder_provider.dart` | Conexión y refresco autorizados; no guardar otra URI de carpeta por separado |
| `lib/presentation/widgets/mario_rom_assets_panel.dart` y `mario_assets_coordinator.dart` | Flujos hermanos que usan ROM; mantener compatibilidad |
| `test/presentation/how_to_play_test.dart` | Cobertura de guía, temas, expansión y navegación que debe conservarse |

La importación gráfica actual lee una ROM completa a memoria para decodificar
recursos; no copiar ese patrón al conversor, que puede procesar bloques.
Preparar una copia no cambia el tema seleccionado ni dispara una extracción.

## 5. Experiencia propuesta

1. Tarjeta **Preparar mi ROM**: «Elige tu archivo. Crearemos una copia compatible
   sin cambiar el original». Acción **Elegir ROM**. Explicar antes del explorador.
2. Selector de documentos Android. Cancelarlo devuelve a la tarjeta sin error.
3. Estado local: **Comprobando archivo**, **Preparando copia**, **Verificando**.
   Progreso real por fase; porcentaje indeterminado si faltan datos fiables.
4. Resultado válido: **ROM lista para CoopDX** y nombre de la copia. Si ya era
   z64, indicar que estaba en el formato correcto y fue comprobada.
5. Acción principal **Guardar copia .z64**; después, **Continuar con el juego**
   conduce al capítulo 3 para elegirla desde el juego.

La primera versión exporta una copia, sin reemplazar la ROM del juego. Funciona
también antes de conectar la carpeta del juego, coherente con el orden de la
guía. El nombre sugerido puede ser `baserom.us.z64`; mostrar el nombre final
devuelto por el proveedor, que puede añadir un sufijo si ya existe.

Una segunda fase podrá ofrecer **Usar en la carpeta del juego**, únicamente
con conexión válida y confirmación. Resolver destino mediante GameFolderStore;
si existe ROM válida, reutilizar; si es distinta, conservarla y diseñar respaldo
y recuperación antes de permitir sustitución. No usar el algoritmo de
borrar-antes-de-crear propio de instalaciones para reemplazar una ROM valiosa.
No prometer sustitución atómica con SAF ni detectar con certeza si el juego
está ejecutándose. Preferir solicitar cerrarlo antes de esa acción futura.

### Diseño en todos los temas

Usar tokens, colores de contraste, fuentes y superficies existentes; no otra
identidad visual. Retro Manga: jerarquía numerada y panel limpio; Minimalista:
tarjetas discretas; Minish Cap: papel/marco existente; MK64: lenguaje de carrera;
Mario64 y SM64 Intro: sus paneles y selección actuales. Evitar nuevos fondos
animados o cargar recursos ROM para mostrar el propio preparador.

Una tarea visible cada vez; nombre largo con ajuste de línea; botones amplios,
texto escalable, lector de pantalla, modo claro/oscuro y landscape. No comunicar
error o éxito solo con color. Deshabilitar doble toque durante operación.
Volver con tarea activa pide cancelar o continuar en la pantalla; no deja un
proceso huérfano silencioso.

### Dos accesos: Cómo jugar y Herramientas/GameTool

Incluir desde la primera versión una herramienta reutilizable en el drawer,
dentro del submenú existente **Herramientas / GameTool**, junto a Biblioteca,
Jugador y Partidas. Nombre propuesto: **Preparar ROM** en español, **ROM
Preparer** en inglés y **Preparar ROM** en portugués BR; confirmar las etiquetas
finales al localizar los cinco ARB. No añadir otro submenú ni un botón principal
independiente del grupo de herramientas.

Crear `lib/presentation/screens/rom_preparation_screen.dart` como pantalla
contenedora, con ruta propuesta `/game-tool/rom-preparer` dentro del AppShell.
Reutilizar `rom_preparation_panel.dart`, el mismo servicio y el mismo provider
desde ambos accesos. La guía ofrece explicación previa y abre esta herramienta;
el drawer permite volver a utilizarla sin recorrer los capítulos de inicio.

Desde Cómo jugar, volver debe conservar el capítulo 2 y su desplazamiento.
El resultado puede ofrecer **Continuar con la guía** hacia el capítulo 3;
no navegar automáticamente al completar ni al cancelar. Desde el drawer,
ofrecer guardar la copia y, como acción secundaria, consultar cómo usarla en el
juego. No mostrar dos instancias capaces de iniciar conversiones simultáneas:
la operación nativa sigue siendo única y una segunda entrada consulta su estado.

Modificar el router `lib/core/router/app_router.dart` y el componente existente
`lib/presentation/widgets/app_drawer.dart`, usado por AppShell. Añadir título, selección de ruta,
semántica e icono coherente con las herramientas existentes. La pantalla usa
el mismo lenguaje visual de cada tema; no una segunda implementación del panel.

Todos los textos nuevos deben estar en los cinco ARB: inglés, español/es-419 y
portugués/pt-BR. Generar localizaciones con Flutter, sin editar Dart generado.

## 6. Arquitectura propuesta — nombres aún no existentes

| Capa | Archivo propuesto | Contrato |
|---|---|---|
| Dominio | `lib/domain/entities/rom_preparation.dart` | Estado, formato, resultado y errores tipados |
| Servicio Flutter | `lib/services/rom_preparation_service.dart` | Canal nativo, eventos y cancelación |
| Provider | `lib/presentation/providers/rom_preparation_provider.dart` | Proyección observable y exclusión de doble operación |
| UI | `lib/presentation/widgets/rom_preparation_panel.dart` | Pasos, progreso y acciones; sin I/O |
| Pantalla | `lib/presentation/screens/rom_preparation_screen.dart` | Contenedor común abierto desde la guía y el submenú Herramientas/GameTool |
| Android | `android/app/src/main/kotlin/mods/sm64cdpy/RomPreparationPlugin.kt` | Picker/exportación, ciclo de Activity y canal |
| Núcleo Android | `android/app/src/main/kotlin/mods/sm64cdpy/RomByteOrderConverter.kt` | Transformación pura sobre streams, comprobable sin UI |

Propuesta de canal: `sm64cdpy/rom_preparation`, separado del importador de assets.
Operaciones conceptuales: seleccionar/preparar, consultar estado, exportar y
cancelar. Eventos con `operationId`, revisión monotónica, fase, bytes procesados,
total si se conoce y error estable. El resultado expone un identificador opaco,
no rutas arbitrarias de archivos privados.

Primera fase: operación interactiva de tamaño acotado en executor nativo o
Dispatchers.IO, según dependencias reales disponibles al implementar. No usar
WorkManager solo por existir: no hay descarga ni promesa de continuar tras
muerte de proceso. La rotación conserva tarea mientras el engine vive; al
destruir el engine se cancela y limpia. Tras muerte del proceso se reinicia el
flujo, sin afirmar que terminó. Si se decide continuar en background, habrá que
rediseñarlo como Worker observable con persistencia y reconciliación completas.

## 7. Algoritmo y seguridad de escritura

1. Abrir URI de entrada **solo lectura**, con ACTION_OPEN_DOCUMENT/OPENABLE;
   aceptar MIME amplio porque proveedores pueden no clasificar estas extensiones.
   No convertir URI a ruta `/sdcard` ni pedir acceso a todos los archivos.
2. Leer exactamente cuatro bytes para detectar formato; conservarlos en el
   procesamiento. No depender de `available`, seek o tamaño declarado.
3. Crear staging privado único por UUID fuera de carpetas de assets/Player.
   Cache temporal, no respaldo ni almacenamiento permanente. Comprobar espacio
   y manejar fallo de escritura igualmente; cacheDir puede ser purgado.
4. Procesar en buffer reutilizable, inicialmente 64 KiB. Acumular lecturas
   cortas y conservar sobrantes de 1–3 bytes entre lecturas. Transformar solo
   grupos completos y escribir solo bytes válidos. Nunca volcar el buffer entero
   si se leyó menos. Rechazar final no alineado.
5. Limitar bytes reales a ROM_SIZE, detectar EOF prematuro y rechazar un byte
   extra. Calcular MD5 de bytes normalizados mientras se escriben. Cerrar y
   sincronizar staging; verificar tamaño/hash antes de marcarlo preparado.
6. Si se solicita exportar, usar ACTION_CREATE_DOCUMENT y copiar staging
   validado a la nueva URI. Cerrar salida, reabrir y verificar tamaño/hash para
   declarar copia guardada. Si no se puede verificar, informar el límite y no
   mostrar éxito confirmado. Mantener staging para reintentar.
7. Fuente original intacta. Nunca pedir escritura sobre ella. Verificar también
   URI de destino distinta de origen como defensa adicional. Limpiar solamente
   staging propio y documentos nuevos de esta operación cuando sea posible.

Fuente de permisos y pickers:
[Android Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files).
La selección de documentos evita permisos generales; ACTION_CREATE_DOCUMENT
crea un documento nuevo y resuelve colisiones de nombre. Sus permisos no
permiten asumir acceso al resto de carpetas. Si hiciera falta conservar una URI
entre reinicios, tomar únicamente los flags persistibles realmente concedidos.
En este flujo inicial la fuente se consume una vez y no se conserva su permiso.

La cancelación comprueba bandera por bloque, puede cerrar stream bloqueado y
espera al trabajador antes de confirmar `cancelled`. Al cancelar exportación,
intentar eliminar solo el documento nuevo parcial; si el proveedor lo impide,
avisar de esa copia incompleta. Nunca borrar el original. Una exportación
verificada confirmada gana frente a una cancelación tardía.

## 8. Estados, errores y ciclo de vida

```text
idle → picking → inspecting → converting/copying → validating → prepared
prepared → choosingDestination → exporting → verifyingExport → saved
operación activa → cancelling → cancelled
operación activa → failed → reintentar / elegir otro archivo
picker cerrado → estado anterior seguro
```

`prepared` significa copia privada compatible; `saved` significa exportación
externa verificada. Ninguno significa juego instalado, iniciado o configurado.
Separar ambos mensajes. No convertir la animación de progreso en autoridad.

Errores previstos: archivo no reconocido, tamaño incorrecto, ROM incompatible,
lectura fallida, permiso revocado, almacenamiento lleno, exportación fallida,
verificación fallida, recurso ocupado y Activity no disponible. Mensaje breve
con acción concreta y detalle técnico copiable. Un hash diferente muestra
«Necesitas la ROM original de Super Mario 64 USA» sin inventar su causa exacta.

Resolver cada respuesta MethodChannel una sola vez; capturar errores y liberar
busy en finally. Ignorar eventos de otra operación/revisión. Quitar observers,
listeners y subscriptions al destruir sus owners; no cancelar por la salida
temporal al picker ni por rotación si el engine continúa.

Staging se conserva durante el flujo para repetir exportación sin reconvertir;
al terminar/cancelar se elimina. Al arrancar, limpiar restos huérfanos propios
con criterio de antigüedad y sin tocar operaciones vivas. No crear historial
de ROM ni persistir progreso de éxito basado solo en nombres de archivo.

## 9. Verificación de sincronización de estado prevista

- **Quién escribe/lee:** trabajador nativo escribe staging/estado de operación;
  servicio y provider Flutter lo leen. UI solicita acciones, no valida archivos.
- **Fuente de verdad:** operación nativa viva y bytes validados. Tras reinicio,
  una tarjeta persistida nunca prueba que existe una ROM válida.
- **Cache:** únicamente staging de sesión; nativo lo invalida al cancelar,
  terminar o limpiar huérfanos. No reutilizar por nombre/tamaño sin hash.
- **Engines:** primera fase solo engine principal. Overlay no comparte variables,
  no inicia preparación ni necesita recibir una exportación externa.
- **Hermanos:** exportar no cambia game-folder, biblioteca, perfil ni assets;
  no invalidarlos innecesariamente. En la futura escritura al juego revisar
  importador de temas, Player3DSource, providers y cualquier caché derivada de ROM.
- **Futures:** esperar selección, preparación, cancelación y exportación. Solo
  callbacks síncronos que lo requieran usarán unawaited con captura de errores.

Este es el contrato a implementar y verificar; no describe estado ya añadido.

## 10. Plan de ejecución y validación

1. Fijar revisiones de referencias; revisar call sites ROM y validar contrato
   contra la versión Android del juego que se probará.
2. Implementar conversor puro y pruebas sintéticas antes de conectarlo a SAF.
3. Integrar plugin, selección, staging, exportación y cancelación; sin UI nueva
   hasta que los resultados/error sean comprobables.
4. Añadir servicio/provider, panel temático y pantalla compartida; registrar
   `/game-tool/rom-preparer`, entrada en Herramientas/GameTool y acceso desde
   capítulo 2. Conservar claves
   PageStorage separadas: expansión guarda bool; textos/listas guardan offsets.
5. Localizar cinco ARB, generar código, sustituir todos los usos del enlace
   externo y actualizar HOW_TO_PLAY, checklist, estado y changelog al implementar.
6. Revisar regresiones de temas/Jugador/carpeta, ejecutar CI y comprobar teléfono.

Pruebas necesarias sin distribuir ROM real:

- Datos sintéticos con cabeceras y vectores de bytes conocidos para n64/v64/z64.
- Lecturas partidas de 1, 2, 3 y tamaños irregulares; límites de buffer y EOF.
- Hash/tamaño con fixtures sintéticas y validador parametrizable en tests; no
  relajar constantes de producción ni incluir ROMs en repositorio/Actions.
- Archivo vacío, truncado, gigante, extensión engañosa, hash incorrecto.
- Cancelar selección, conversión y exportación; limpieza y cancelación tardía.
- Proveedor sin seek, tamaño desconocido, lectura corta, permiso revocado,
  escritura fallida, espacio lleno y exportación que no pasa verificación.
- Doble toque, salida/retorno, rotación, background, destrucción de engine y
  muerte de proceso sin loading permanente ni éxito falso.
- Widgets en seis temas, claro/oscuro, tres idiomas, texto grande y pantalla
  pequeña. Conservar pruebas de ayudas desplegables y navegación de la guía.
- Entrada desde drawer y guía, ruta seleccionada, retorno al capítulo original,
  consulta de una operación ya activa y acción de continuar tras guardar. Añadir
  `test/presentation/rom_preparation_screen_test.dart` y ampliar pruebas del
  drawer/router existentes; verificar que ambos accesos usan el mismo estado.

En dispositivo y con ROM propia: comparar hash de las tres variantes tras
normalizar, medir duración/memoria en gama baja y verificar que el juego acepta
la copia exportada. No prometer un segundo universal: el proveedor puede ser
lento o remoto. Limitar actualizaciones de progreso aproximadamente a 100–250 ms;
una sola transformación secuencial evita presión de memoria innecesaria.

Validaciones de implementación: dart format, flutter gen-l10n si cambia ARB,
flutter analyze lib, tests relevantes, compileDebugKotlin y git diff --check.
En Termux sin Flutter/SDK, declarar comprobaciones locales imposibles y usar CI;
compilación correcta no reemplaza pruebas físicas con proveedor y juego reales.

## 11. Criterio de aceptación

El usuario comprende por qué se abre el selector, conserva su original, obtiene
una copia USA válida o una explicación accionable, puede cancelar y sabe dónde
guardó el resultado. Preparar no altera configuración, mods, partidas ni tema.
La integración inicial se limita a exportar y continuar la guía; instalar o
reemplazar directamente en user requiere la segunda fase descrita arriba.

## 12. Obtener una copia del propio cartucho: ayuda propuesta

Añadir una ayuda opcional **¿Cómo obtengo mi ROM?** antes de elegir archivo.
Explicar que la ROM contiene los datos del cartucho y que el preparador recibe
un archivo que el usuario ya tiene: la app no lee físicamente cartuchos ni
incluye un juego. Separar extracción, conversión y comprobación de compatibilidad.

Una vía técnica documentada es utilizar un lector de cartuchos compatible con
Nintendo 64, como Open Source Cartridge Reader (OSCR). Referencias del proyecto:

- [Qué pedir / componentes](https://github.com/sanni/cartreader/wiki/What-to-order):
  lista para construir el lector; no es una guía jurídica ni un enlace a ROMs.
- [Leer un cartucho N64](https://github.com/sanni/cartreader/wiki/Read-N64-cartridge):
  instrucciones específicas de lectura y preparación del equipo.

La página de componentes muestra diferentes piezas y configuraciones: enlazar
la documentación correspondiente al hardware, sin copiar ajustes eléctricos
como si fueran universales. Montar un lector requiere conocimientos; para
menores, indicar ayuda de una persona adulta. No presentar una compra concreta
como requisito de la app ni fijar precios o disponibilidad. El repositorio
consultado aparece archivado: revisar enlaces antes de publicar la ayuda.

### Recorrido sencillo para la futura guía

1. **Tu cartucho:** disponer de una copia legítima del juego. Para el flujo
   compatible estudiado se necesita el contenido de la edición USA original;
   un cartucho europeo no se transforma en USA con el preparador.
2. **Un lector compatible:** seguir la guía del fabricante/proyecto y las
   instrucciones de seguridad de su modelo. Usar la función de lectura de ROM;
   no escribir ni borrar cartucho o partida.
3. **Obtener el archivo:** extraer una copia con el equipo, conforme a la ley
   aplicable. La documentación N64 de OSCR explica la preparación de la tarjeta
   SD y la lectura. No inventar una secuencia de botones común a todos los lectores.
4. **Pasarlo al teléfono:** transferir el archivo generado desde la tarjeta o
   el ordenador mediante un método disponible, conservando una copia original.
5. **Prepararlo en SM64CDPY:** elegir ese archivo; normalizar si hace falta y
   comprobar tamaño/hash. Un resultado compatible identifica contenido técnico,
   no acredita propiedad ni permisos legales.

### Orientación por países: México

Usar nombres de países y territorios jurídicos, sin ciudades ni inferencias
sobre la ubicación del usuario. La región **USA de la ROM** es un requisito
técnico del juego, independiente del país donde vive la persona.

El artículo 105 de la
[Ley Federal del Derecho de Autor de México, texto vigente](https://www.diputados.gob.mx/LeyesBiblio/pdf/LFDA.pdf)
permite al usuario legítimo las copias autorizadas por la licencia o una copia
bajo las condiciones legales: indispensable para utilizar el programa, o
exclusivamente de resguardo para sustituir la copia adquirida si queda inutilizable
por daño o pérdida. El respaldo debe destruirse al cesar el derecho de uso.

Ese artículo no declara autorizado todo volcado de videojuego para jugar en
otro sistema. También deben considerarse los artículos 114 Bis y siguientes
sobre medidas tecnológicas y sus excepciones. No afirmar ausencia de
jurisprudencia específica sin una investigación judicial suficiente, ni prometer
que una interpretación sea «la más defendible» para cualquier caso.

### Estados Unidos (USA)

La [sección 117 del título 17](https://www.copyright.gov/title17/92chap1.html#117)
contempla, para el propietario de una copia de un programa, copias en supuestos
concretos, como el paso esencial para utilizarlo con una máquina o el archivo
exclusivo, con sus condiciones. Una copia de archivo no equivale automáticamente
a autorización para usar sus recursos en otro port. La
[Copyright Office explica los límites de los respaldos](https://www.copyright.gov/help/faq/faq-digital.html).

La [sección 1201](https://www.copyright.gov/title17/92chap12.html#1201)
regula por separado la elusión de controles efectivos de acceso y establece
excepciones. No asumir que la falta de cifrado descarta una medida tecnológica:
el concepto legal no se limita al cifrado. No concluir que el riesgo es bajo
por tratarse de N64 o uso personal. Las opiniones de un fabricante no sustituyen
la ley ni una decisión judicial sobre un caso concreto.

### Europa y la Unión Europea

Evitar el título «Obtén tu ROM legalmente en Europa» como garantía general.
Europa incluye países fuera de la UE; incluso dentro de la UE hay que atender
la legislación nacional y las circunstancias del uso.

El artículo 5.2 de la
[Directiva 2009/24/CE](https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32009L0024)
establece que no puede impedirse por contrato una copia de seguridad realizada
por quien tiene derecho a usar el programa, en la medida en que sea necesaria
para esa utilización. No es una autorización general para cualquier copia,
descarga o uso posterior. Esa disposición por sí sola no demuestra que usar una
ROM extraída en este port esté autorizado en todos los casos.

El TJUE explicó en Nintendo/PC Box, C-355/12, que los videojuegos incluyen también
elementos gráficos y sonoros con protección propia y abordó los límites de la
protección de medidas tecnológicas. Por ello no basta aplicar automáticamente
la excepción de software a todo el juego. Véase el
[comunicado oficial del TJUE sobre la sentencia](https://curia.europa.eu/jcms/upload/docs/application/pdf/2014-01/cp140009en.pdf).
No deducir que poseer un cartucho permite eludir cualquier protección o
compartir su ROM. La guía técnica del lector tampoco determina esa legalidad.

### Reino Unido

La [sección 50A de Copyright, Designs and Patents Act 1988](https://www.legislation.gov.uk/ukpga/1988/48/section/50A)
contempla una copia de respaldo necesaria para el uso legítimo de un programa
por su usuario legítimo. No presentarlo como permiso general de copia privada
de videojuegos ni como autorización para cualquier uso posterior. Reino Unido
se trata separadamente de la UE; comprobar texto vigente y demás reglas
aplicables antes de publicar una conclusión específica.

### Otros países y límites de esta orientación

No extrapolar estas excepciones a Brasil u otros países sin revisar fuentes
nacionales. Idioma, país del usuario y región del cartucho son datos distintos;
no elegir automáticamente la explicación jurídica por idioma o GPS.

Para redactar la ayuda, conservar estas distinciones:

- **Extraer el cartucho propio:** método técnico que debe evaluarse bajo la ley
  aplicable; propiedad y uso personal no bastan para garantizar legalidad.
- **Descargar de terceros:** poseer el cartucho no concede por sí solo permiso
  para obtener una copia de una fuente no autorizada. La app no enlaza ROMs.
- **Compartir volcados:** una excepción de respaldo no concede por sí sola
  derecho a distribuirlos. No ofrecer subida, intercambio ni publicación.
- **Emulación y ports:** no usar «todos los emuladores son legales» como garantía
  para esta app; software, ROM, recursos del juego y medidas tecnológicas son
  cuestiones separadas. El preparador no determina derechos sobre ninguna.

Evitar tanto «todo es ilegal» como «es una zona gris de muy bajo riesgo».
Describir las condiciones verificadas y dejar explícito qué no se ha resuelto.
No recomendar Retrode, EverDrive u otro equipo como lector de cartuchos sin
comprobar que el modelo y accesorios permiten extraer precisamente N64:
cargar ROMs y extraerlas de un cartucho son funciones distintas.

Texto breve propuesto para la interfaz, pendiente de localización:

> Puedes obtener un archivo de tu propio cartucho con un lector compatible.
> Consulta las normas de tu país sobre copias y medidas de protección.
> SM64CDPY no incluye ni proporciona ROMs.

La explicación ampliada y las fuentes quedan en una ayuda secundaria; no añadir
un formulario jurídico ni una casilla que finja comprobar derechos. Mantener
como acciones separadas **Ver guía del lector** y **Ya tengo mi archivo**.
Esta sección es orientación general para redactar el producto, no una conclusión
jurídica sobre la situación de cada usuario. Antes de presentar afirmaciones
legales específicas para un país, verificarlas con fuentes nacionales vigentes.
