# Temas propios incluidos: implementación y flujo de trabajo Android

Actualizado: 2026-10-13. Rama local: `custom-themes`, creada desde el `main` local (`8bdc996`). Versión de la app conservada: `1.8.2+21`. Estado: el usuario confirmó que la build y prueba anteriores funcionaron. La reducción a dos temas y los menús coherentes requieren una nueva ejecución de Actions y revisión física. No es una release publicada.

## 1. Qué se implementó

Ajustes → Apariencia contiene un menú expandible **Tema de interfaz**. Ofrece dos diseños incluidos en el código: Retro Manga y Mario 64. El usuario elige uno; tú mantienes sus definiciones. Un segundo menú expandible, con el mismo estilo, permite claro, oscuro o seguir el sistema. Cada encabezado muestra la selección actual y despliega sus opciones al pulsarlo.

Son primeras interpretaciones visuales propias, creadas con colores y geometría Flutter. No incluyen imágenes, fuentes o interfaces extraídas de juegos ni pretenden reproducir exactamente sus menús. Puedes ajustar cada diseño sin rehacer los flujos del catálogo. Todas las definiciones están incluidas en el APK y no requieren red.

| ID persistido | Definición | Configuración inicial |
|---|---|---|
| `retro_manga` | `lib/core/theme/themes/retro_manga_theme.dart` | Formas rectas, sombra dura, inclinación, puntos y franjas; conserva el diseño anterior con ajustes de contraste del texto secundario y acento textual claros |
| `mario64` | `lib/core/theme/themes/mario64_theme.dart` | Superficies azules, acento rojo/rosado según brillo, radio 12, sombra dura, sin inclinación ni decoraciones manga |

El cambio no reinicia `ProviderScope`, no altera la ruta actual, no borra favoritos y no cancela descargas. La selección cambia presentación; contenido, identidad de operaciones y destino de instalación conservan su lógica existente.

## 2. La burbuja y Android: decisión aplicada

La burbuja comparte el archivo `retro_theme.dart`, pero **su instancia es independiente**: `RetroTheme.overlay()` y el engine iniciado por `overlayMain()`. No obtiene su selección de Hive ni del provider principal.

Se adaptó esa raíz para construir su ThemeData completo desde `RetroTheme.overlay().toMaterialTheme()`. Así los widgets Material y los tokens personalizados usan la misma paleta fija. El panel sigue oscuro, con sus colores anteriores de fondo y superficies. No se añadieron mensajes de tema, ni lectores de preferencias del overlay, ni cambios a `overlay_bridge.dart` o `overlay_panel.dart`.

Esta es la integración necesaria de la dependencia compartida; la selección de diseños para el overlay queda expresamente fuera de esta fase. El texto del menú explica que la selección afecta a la app y el panel conserva su diseño oscuro.

Android nativo no requiere cambios para este selector. Se revisaron `MainActivity.kt`, `ModInstallerPlugin.kt`, `ModDownloadWorker.kt`, `ModInstallWorker.kt`, `SafZipExtractor.kt`, `InstallIdentityMetadata.kt`, `InstallationReceiptStore.kt`, `InstallationSafVerifier.kt` e `InstallationDiscoveryScanner.kt`. Ninguno recibe ni guarda IDs de tema.

`AndroidManifest.xml`, `values/styles.xml`, `values-night/styles.xml`, ambos `launch_background.xml`, strings nativos, iconos y Gradle permanecen como en `main`. El splash todavía sigue sus recursos Android y no lee el diseño de Hive. Las barras del sistema se ajustan desde Flutter con el brillo efectivo; las restricciones de Android sobre edge-to-edge y sus superficies requieren comprobación física.

## 3. Contrato visual central

### `lib/core/theme/app_theme_design.dart`

Contiene `AppThemeId`, `AppThemePalette` y `AppThemeDesign`.

- `AppThemeId.storageKey` es identidad estable; no guardar nombre traducido ni posición de la lista.
- `fromStorage()` devuelve Retro Manga ante ausencia o ID desconocido. Así una instalación anterior conserva su modo y tiene un diseño válido.
- Cada diseño contiene una paleta clara y otra oscura.
- Cada paleta define fondo, superficie, superficie alternativa, borde, sombra, tinta principal/secundaria, acento, texto sobre acento y acento legible para texto sobre superficies.
- El diseño define radio, escala de borde, blur y escala de desplazamiento de sombra, inclinación de chip, peso/tracking de títulos, familias tipográficas, tratamiento de mayúsculas y activación de puntos/franjas.

Los diseños actuales no agregan fuentes. Las familias son opcionales; si más adelante las usas, incluye sus archivos en assets y decláralos en `pubspec.yaml`.

### `lib/core/theme/app_theme_catalog.dart`

Registro inmutable y orden visible de diseños. `resolve()` convierte un ID conocido en su definición. Cada miembro del enum debe tener exactamente una definición registrada. Las pruebas recorren el catálogo; no mantener un catálogo diferente para previews.

### `lib/core/theme/retro_theme.dart`

`RetroTheme` ahora es `ThemeExtension<RetroTheme>`. Se mantuvo el nombre y las firmas de consumo para evitar renombrar todas las pantallas. `RetroTheme.of(context)` busca la extensión del ThemeData; solo usa la apariencia Retro por brillo como fallback cuando un contexto no tiene extensión.

La misma instancia produce `toMaterialTheme()`: ColorScheme, fondo de Scaffold, AppBar, diálogos, sheets y formas de botones. Así el color Material y el de una tarjeta dibujada a mano no salen de fuentes distintas.

- `radius` dejó de ser una constante estática: es una propiedad del diseño activo.
- `borderWidth(valorRetro)` conserva el énfasis relativo del borde multiplicándolo por la escala del diseño.
- `hardShadow()` conserva su API, pero aplica blur y escala de offset del diseño.
- `heading()` y `body()` aceptan las familias del diseño. Los encabezados dibujados con TextStyle local también consumen peso/familia central.
- `onColor(color)` usa el foreground explícito del acento y compara contraste entre negro y blanco para otros rellenos. `accentText` evita usar un acento claro como texto sobre papel claro; las etiquetas respetan mayúsculas solo cuando el diseño lo solicita.
- `copyWith()` conserva overrides; `lerp()` interpola paleta y propiedades numéricas y conserva extremos.
- La raíz principal aplica cambios sin animación de tema (`Duration.zero`) para evitar una mezcla temporal de foreground y fondo incompatible.

Los colores de estado, categorías, medallas y Discord mantienen su semántica. Blanco sobre fotografías, scrims y geometría circular de badges siguen cumpliendo su función. El pequeño radio del tirador de sheet también es geometría estructural. No se transformaron indiscriminadamente en el acento del tema.

Los componentes de trama y franjas consultan el diseño del contexto. Desactivarlos funciona tanto en `AppShell` como en los banners locales de Render96 y tarjetas. Los chips, tags y badges obtienen el foreground adecuado de sus rellenos.

## 4. Fuente de verdad y flujo exacto

```text
Hive: theme_id + theme_mode
    ↓ lectura segura en AppearanceNotifier.build()
AppearanceSettings(themeId, mode, isSaving)
    ↓ providers derivados, observando los valores y no la instancia del notifier
main.dart: variantes ThemeData clara y oscura
    ↓ MaterialApp selecciona variante según modo/brillo del teléfono
ThemeExtension RetroTheme + ColorScheme
    ↓ pantallas, widgets, diálogos, fondos y barras del sistema
```

### Inicio y compatibilidad

1. El bootstrap intenta abrir la caja Hive existente de Ajustes.
2. El notifier lee `theme_id` y `theme_mode` mediante un lector seguro.
3. Sin ID o con ID desconocido, selecciona Retro Manga. Un modo existente claro/oscuro se conserva; un modo inválido cae en sistema.
4. Si la caja no está abierta, usa Retro Manga/sistema en memoria. También se protegió la lectura inicial de locale para que el mismo árbol no falle por esa caja ausente.
5. No se borra ni recrea la caja de Ajustes. Una selección guardada posterior escribe claves válidas.

Las preferencias guardadas de `odyssey` o `gamecube` se interpretan como Retro
Manga al arrancar y conservan su `theme_mode`. No hay diseños retirados en enum,
registro o menú. Al confirmar una selección (incluso el fallback ya visible),
el escritor compara también las claves persistidas y sustituye el ID retirado;
no considera ese caso un guardado innecesario.

### Selección

1. `AppearanceSelector` solicita `setTheme(id)` o `setThemeMode(mode)`.
2. El notifier rechaza una segunda solicitud mientras guarda. La UI desactiva las opciones durante ese periodo.
3. Publica `isSaving: true` conservando ID y modo confirmados.
4. Espera `Hive.putAll()` con las dos preferencias coherentes.
5. En éxito publica nueva selección y libera el guardado. Los providers derivados reconstruyen la apariencia.
6. En fallo restaura el estado anterior, libera los controles y devuelve `false`. El widget comprueba `context.mounted` y muestra un error localizado accionable.
7. Si el propietario del provider fue destruido durante el await, no escribe estado en un Ref desmontado. La escritura que sí terminó queda disponible para el siguiente arranque.

No hay una cola de selecciones que pueda finalizar fuera de orden. Una selección ya confirmada no vuelve a escribirse innecesariamente. Un usuario puede cambiar de diseño de nuevo cuando termine la escritura anterior.

### Sistema, navegación y operaciones

`main.dart` observa modo y diseño. MaterialApp sigue el brillo del teléfono cuando el modo es sistema; la extensión pertenece a la variante efectiva. `AnnotatedRegion<SystemUiOverlayStyle>` y AppBar leen esos tokens, en lugar de consultar un booleano cacheado que solo escuchaba la instancia del notifier.

No hay observador manual de brillo ni timer nuevo que limpiar. La raíz conserva router y providers. La coordinación global de descargas e instalaciones permanece dentro del builder y no recibe una key distinta por diseño.

Sheets usan la forma/fondo del tema Material, sin almacenar sus colores en los argumentos de apertura. Sus contenidos reconstruyen tokens en build. Diálogos de instalación y lanzamiento obtienen tokens del contexto del diálogo. Snackbars resuelven su decoración desde un Builder para responder a cambios de Theme.

## 5. Qué se adaptó en toda la interfaz

Se revisaron las 14 pantallas de la app y sus componentes compartidos, incluidos carga/error/vacío, detalles, Biblioteca y OTA. La galería fullscreen conserva su fondo negro e iconos claros de las barras; la cabecera sobre fotos de detalle también mantiene foregrounds claros hasta volverse sólida. Se migraron radios y grosores, sombras locales, inclinaciones propias de Home, títulos locales y recortes de imágenes.

| Pantalla | Adaptación principal |
|---|---|
| Home | Carousels, tarjetas, botones, chips locales, títulos sobre fotos, recortes y diálogo de lanzamiento |
| Catálogo | Búsqueda, filtros, orden, sheet, paginación y selección con foreground correcto |
| Favoritos | Tarjetas/estado vacío y botón de exploración |
| Popular | Podio, medallas, paginación, sombras y foregrounds según relleno |
| Detalle | Iconos de cabecera, versiones, archivos, diálogos, sheets, galería y botones |
| VIP | Tarjetas, acciones y carga; mantiene semántica dorada |
| DynOS | Tarjetas/acciones; texto y progreso sobre azul usan foreground de azul |
| Touch Controls | Tarjetas/acciones; texto y progreso sobre acento usan onAccent |
| OMM | Tarjetas/acciones; texto y progreso sobre rojo usan foreground de rojo |
| Render96 | Hero, trama/franjas, tarjeta principal, acciones y variantes de carga/error |
| Biblioteca | Filtros/sheets, cards de recibos/historial y estados vacíos |
| Ajustes | Menú nuevo y decoración de tiles, diálogos, toggles y locale |
| Links | Tarjetas y cabeceras |
| Disclaimer | Paneles informativos y contacto; marca Discord conserva su color |

Bordes parciales usados como líneas o barras laterales conservan su geometría. No se les aplican radios incompatibles con el pintado de bordes no uniformes de Flutter. Las formas de tarjetas que contienen esas líneas sí pueden responder al tema.

## 6. Añadir tu siguiente tema, sin copiar pantallas

1. Añadir un miembro a `AppThemeId`, con `storageKey` estable.
2. Crear `lib/core/theme/themes/<nombre>_theme.dart`, importando `app_theme_design.dart`.
3. Definir ambas paletas y los parámetros de forma/decoración. Usar una pareja explícita acento/onAccent y un `accentText` legible sobre las tres superficies.
4. Importarlo y añadirlo a `AppThemeCatalog.designs` en el orden deseado.
5. Añadir su nombre localizado al switch `_name()` de `AppearanceSelector`.
6. Añadir esa clave a `app_en.arb`, `app_es.arb`, `app_es_419.arb`, `app_pt.arb` y `app_pt_BR.arb`.
7. Añadir assets/fuentes locales solo si el diseño los necesita; declararlos en `pubspec.yaml`.
8. Generar localizaciones y formatear en Actions o en una máquina con Flutter. Nunca editar `app_localizations*.dart` a mano.
9. Ejecutar las pruebas automáticas y la matriz física de esta guía.
10. Registrar diseño y cambios en documentación/checklist; actualizar la versión/manifiesto de release únicamente cuando se prepare un lanzamiento.

Normalmente se editan enum, registro, mapa de nombres, cinco ARB y se crea una definición: **9 archivos escritos manualmente**, más assets, pubspec si aplica y documentación. No hace falta modificar las 14 pantallas para otro diseño que use los roles existentes.

Ejemplo de estructura de una definición futura (esquema, no copiar valores incompletos):

```dart
const myDesign = AppThemeDesign(
  id: AppThemeId.myDesign,
  light: myLightPalette,
  dark: myDarkPalette,
  cornerRadius: 14,
  borderScale: 0.6,
  shadowBlur: 10,
  shadowOffsetScale: 0.5,
  chipSkew: 0,
  halftone: false,
  stripes: false,
);
```

Si necesitas una propiedad nueva —por ejemplo textura de fondo o iconografía de navegación— añadirla al contrato, consumirla en el componente central correspondiente y documentar su fallback. Una composición radicalmente distinta puede necesitar una variante de un componente; no añadir condiciones por ID en cada pantalla. Esta fase prepara paletas, formas, tipografía configurable y decoración existente; no implementa un motor arbitrario de layouts ni un editor de temas.

## 7. Localización y generación pendiente

Se conservan 9 claves en los cinco ARB: título/descripción del menú, dos nombres, tres modos, fallo de guardado y estado de guardado. El selector anterior tenía modos en inglés fijo; ahora son localizados.

En Termux no hay `flutter` ni `dart` en PATH. Los cuatro archivos `app_localizations*.dart` existentes permanecen sin editar manualmente: el checkout contiene las nuevas referencias de UI y las definiciones ARB, y **necesita ejecutar `flutter gen-l10n` antes del análisis** para generar esos getters. Ambos workflows ahora hacen esa generación explícita antes de analizar.

## 8. Pruebas añadidas y qué falta validar

| Prueba | Casos |
|---|---|
| `test/core/theme/app_theme_test.dart` | Catálogo/IDs, contraste de textos y rellenos, coherencia Material/tokens, interpolación, overlay fijo y eliminación de decoración manga |
| `test/presentation/appearance_provider_test.dart` | Preferencia legacy, persistencia entre containers, solicitudes simultáneas, error de almacenamiento y arranque sin caja |
| `test/presentation/appearance_selector_test.dart` | Selección real desde menú, tokens y forma Mario 64, apertura/cierre y selección del modo, cambio de brillo del sistema y ausencia de excepciones de widgets |

Se prepararon para ejecutarse en GitHub Actions; no se afirma que hayan pasado en este dispositivo. Las pruebas existentes de dominio, identidad e instalación siguen incluidas en `flutter test`.

Comprobaciones locales realizadas con las herramientas disponibles: `git diff --check`, carga JSON/paridad de claves de ARB, carga YAML/orden de generación en workflows, revisión de delimitadores/strings Dart y cálculo independiente de contraste de 40 parejas de texto/fondo y acento/foreground. Esas comprobaciones **no equivalen a `flutter analyze`, Dart format, Flutter tests ni un APK compilado**.

### Matriz física pendiente

- Cada diseño en claro, oscuro y seguir el teléfono; cambio de brillo con la app abierta.
- Abrir Ajustes, expandir menú, cambiar repetidamente y reabrir app.
- Verificar selección persistida tras rotación, minimizar y muerte del proceso.
- Recorrer las 14 pantallas, navegación y estado vacío/carga/error.
- Texto grande, horizontal, pantalla pequeña y contraste de acciones/progreso.
- Abrir diálogos/sheets y cambiar brillo del teléfono mientras están visibles.
- Cambiar tema durante descarga e instalación; comprobar progreso, final y cancelación.
- Verificar auto-install on/off y destinos mods/DynOS sin cambios de comportamiento.
- Abrir la burbuja antes/después de cambiar diseño; debe conservar su paleta fija y sus operaciones.
- Revisar barras Android y transición del splash, especialmente en dispositivos con edge-to-edge.

## 9. Flujo en Termux y GitHub Actions

La rama `flutter-termux` fue eliminada localmente y los cambios sin commit de aquella sesión se descartaron, incluida la guía de planificación anterior. Esta guía describe la implementación nueva. No se modificó `main` ni se eliminó ninguna rama remota. No se ejecutaron push, commit, Actions ni publicación.

Para revisar localmente:

```sh
git branch --show-current
git status --short
git diff --stat
git diff --check
```

Cuando tú decidas subir esta rama, el workflow de prueba se ejecuta manualmente seleccionando `custom-themes`, o por un push cuyo mensaje de commit contenga `[testing]`. No necesitas usar el workflow de publicación para obtener el APK de prueba.

El orden de prueba es: Java/Flutter → dependencias → `flutter gen-l10n` → Dart format en el runner → parche de fuentes → análisis/log → `flutter test` → APK arm64 → artifact. El workflow mantiene sus secretos de firma existentes y no crea releases ni tags.

El artifact `flutter-source-sync` contiene `flutter-source-sync.patch`: cambios generados y de formato del runner. Puedes revisarlo y aplicarlo en el mismo commit local con `git apply --check` y después `git apply`; no aplicarlo sin revisar si tu copia ya avanzó. Esto permite incorporar la generación/formato aun trabajando en Termux sin SDK. El runner no hace commits por ti.

El workflow de publicación también genera localizaciones y formatea antes de analizar, pero no fue ejecutado ni está autorizado como parte de esta tarea. La versión y los manifiestos de release no se cambiaron.

## 10. Registro de cambios de desarrollo de esta rama

- Menú de diseños propios incluidos y menú de modo de brillo independiente; ambos usan el mismo componente expandible y opciones verticales.
- Retirados Odyssey y GameCube por decisión del usuario; fallback y confirmación de preferencias antiguas cubiertos por pruebas.
- Contrato visual, catálogo y dos definiciones.
- Persistencia confirmada, protección contra solicitudes simultáneas y fallback.
- Integración transversal de formas, contraste y decoración; brillo efectivo en barras.
- Conservación explícita del overlay fijo desde la misma clase compartida.
- Localizaciones ARB, pruebas y generación/formato en Actions.
- Primera ejecución de Actions: análisis detenido por `final retro = retro` en
  `_BrowseCardState.build()`. Corregido para resolver `RetroTheme.of(context)`.
  Revisados todos los inicializadores autorreferentes en `lib/` y `test/`;
  no se encontró otro caso. Pendiente repetir análisis/tests/build en Actions.
- Segunda ejecución (#173): análisis sin incidencias; 63 tests pasaron y uno
  de decoración falló. Se ajustó su harness para esperar el árbol estabilizado,
  acotar búsquedas a cada decoración y verificar desactivación/reactivación en
  todos los diseños. El resumen recibido no incluye la excepción concreta;
  no se certifica la causa exacta ni el resultado del cambio sin repetir Actions.
  Testing conserva ahora el log expandido completo como `flutter-test-log`.
- Pendientes: ejecución completa de Actions, incorporación opcional de su parche y matriz física.

Este registro es el changelog de desarrollo. No crea un manifiesto de lanzamiento para una versión todavía no elegida ni altera notas de una release ya publicada.

## 11. Verificación de sincronización de estado

- **Escritor:** `AppearanceNotifier`, llamado desde `AppearanceSelector`. Lee/escribe las dos preferencias de apariencia en la caja Hive existente.
- **Lectores:** providers derivados, `SM64CoopDXApp`, la extensión contextual y todas las superficies de presentación. Locale conserva su contrato separado.
- **Fuente de verdad:** Hive para recuperación; Riverpod proyecta la selección confirmada. En modo sistema, MaterialApp resuelve brillo del teléfono.
- **Sincronización:** código conectado de extremo a extremo en el engine principal; ejecución y comportamiento físico pendientes. Overlay tiene una política fija independiente y no replica estas preferencias.
- **Caches:** no se añadió un cache mutable de paleta, timer ni lector nativo. Providers derivados observan valores y ThemeData reemplaza sus tokens al cambiar ID/modo.
- **Futures:** selección y persistencia se esperan; callbacks async esperan sus operaciones y comprueban mounted. No se introdujeron `unawaited` ni `.then` para guardar apariencia. El diálogo posterior a instalación ahora espera su cierre desde el helper.
- **Limpieza/ciclo de vida:** no se crean subscriptions/observers nuevos. Ref desmontado no recibe estado tras guardar. Providers de operaciones y router no se recrean por cambiar tema.
- **Hermanos:** General, VIP, DynOS, Touch Controls, OMM, Render96, detalle, Biblioteca, Home, Popular, Favoritos, Ajustes, Links, Disclaimer, tarjetas, snackbars, diálogos y OTA. Se revisó la dependencia compartida del overlay y se preservó su aislamiento.

## 12. Inventario completo de archivos Dart de `lib/`

La tabla siguiente deja explícito qué participa y qué queda ajeno al tema. Revisar un archivo no implica modificarlo si no maneja presentación. Los generados se enumeran por separado y no se escriben a mano.

| Archivo Dart | Tratamiento |
|---|---|
| `lib/core/constants/app_constants.dart` | Revisado; constantes/utilidades ajenas al contrato visual |
| `lib/core/constants/category_constants.dart` | Revisado; colores semánticos de categoría conservados |
| `lib/core/router/app_router.dart` | Revisado; mismas rutas y navegación, sin ruta extra para el menú |
| `lib/core/theme/app_theme_catalog.dart` | Nuevo: contrato/registro/definición incluida |
| `lib/core/theme/app_theme_design.dart` | Nuevo: contrato/registro/definición incluida |
| `lib/core/theme/retro_theme.dart` | Adaptado: extensión/fachada y componentes comunes |
| `lib/core/theme/themes/mario64_theme.dart` | Nuevo: contrato/registro/definición incluida |
| `lib/core/theme/themes/retro_manga_theme.dart` | Nuevo: contrato/registro/definición incluida |
| `lib/core/utils/extensions.dart` | Revisado; constantes/utilidades ajenas al contrato visual |
| `lib/data/datasource/dynos_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/datasource/local_mod_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/datasource/omm_rebirth_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/datasource/remote_json_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/datasource/render96_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/datasource/touch_control_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/datasource/vip_mod_datasource.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/models/dynos_model.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/models/mod_model.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/models/omm_rebirth_model.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/models/render96_model.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/models/touch_control_model.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/models/vip_mod_model.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/repositories/installation_library_repository_impl.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/data/repositories/mod_repository_impl.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/dynos_entity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/install_identity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/installation_action.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/installation_catalog.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/installation_library.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/mod_entity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/mod_version_resolver.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/omm_rebirth_entity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/render96_entity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/touch_control_entity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/entities/vip_mod_entity.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/repositories/installation_library_repository.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/domain/repositories/mod_repository.dart` | Inventariado y revisado para dependencias visuales; capa de datos/dominio sin tema |
| `lib/l10n/app_localizations.dart` | Generado; pendiente de gen-l10n en Actions, no editado manualmente |
| `lib/l10n/app_localizations_en.dart` | Generado; pendiente de gen-l10n en Actions, no editado manualmente |
| `lib/l10n/app_localizations_es.dart` | Generado; pendiente de gen-l10n en Actions, no editado manualmente |
| `lib/l10n/app_localizations_pt.dart` | Generado; pendiente de gen-l10n en Actions, no editado manualmente |
| `lib/main.dart` | Integrado: selección, ThemeData efectivo, barras y raíz fija del overlay |
| `lib/overlay/overlay_bridge.dart` | Revisado; panel/bridge/datos separados, selección de temas del overlay fuera de esta fase |
| `lib/overlay/overlay_panel.dart` | Revisado; panel/bridge/datos separados, selección de temas del overlay fuera de esta fase |
| `lib/overlay/overlay_sections.dart` | Revisado; panel/bridge/datos separados, selección de temas del overlay fuera de esta fase |
| `lib/presentation/providers/extra_providers.dart` | Revisado; estado de catálogo/operaciones/biblioteca, no guarda selección visual |
| `lib/presentation/providers/installation_action_provider.dart` | Revisado; estado de catálogo/operaciones/biblioteca, no guarda selección visual |
| `lib/presentation/providers/installation_library_provider.dart` | Revisado; estado de catálogo/operaciones/biblioteca, no guarda selección visual |
| `lib/presentation/providers/installation_update_provider.dart` | Revisado; estado de catálogo/operaciones/biblioteca, no guarda selección visual |
| `lib/presentation/providers/mod_providers.dart` | Revisado; estado de catálogo/operaciones/biblioteca, no guarda selección visual |
| `lib/presentation/providers/theme_provider.dart` | Adaptado: escritor único de apariencia, providers derivados y lectura segura |
| `lib/presentation/screens/catalogue_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/disclaimer_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/dynos_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/favourites_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/home_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/library_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/links_resource_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/mod_detail_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/omm_rebirth_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/popular_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/render96_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/settings_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/touch_controls_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/screens/vip_mods_screen.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/app_drawer.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/app_shell.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/app_snackbar.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/appearance_selector.dart` | Nuevo: menú incluido, previews, modos, guardado/error y localización |
| `lib/presentation/widgets/background_operation_coordinator.dart` | Revisado; permanece coordinando resultados globales y usa AppSnackbar tematizado |
| `lib/presentation/widgets/dynos_install_flow.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/installation_action_presentation.dart` | Revisado; labels/iconos/acciones de instalación, no almacena estilos de tema |
| `lib/presentation/widgets/installation_library_card.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/mod_card.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/presentation/widgets/post_install_dialog.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |
| `lib/services/background_install_service.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/download_url_resolver.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/game_launcher_service.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/installation_library_projection_service.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/installation_library_update_bus.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/mod_installer.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/update_config.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/services/update_service.dart` | Revisado en la frontera de presentación; sin cambios en operaciones/plataforma/OTA |
| `lib/widgets/update_dialog.dart` | Adaptado: consumidor visual; formas/contraste/decoración según su función |

Total: 84 archivos Dart en `lib/` enumerados. Esta es una auditoría temática, no una certificación exhaustiva de cada método de descarga/SAF.

## 13. Referencias técnicas

El contrato utiliza las APIs oficiales [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html), [AnnotatedRegion](https://api.flutter.dev/flutter/widgets/AnnotatedRegion-class.html) y [Ref.mounted](https://pub.dev/documentation/riverpod/latest/riverpod/Ref/mounted.html). La versión objetivo de compilación sigue siendo Flutter 3.41.7 con el lockfile del repositorio, no la última versión de esas páginas.
