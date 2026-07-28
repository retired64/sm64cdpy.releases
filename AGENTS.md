# Prompt — Implementación del Panel Flotante (Overlay) — SM64CoopDX Mods

Copia y pega este prompt completo en tu IA local (opencode). Está diseñado
para ejecutarse en **tres fases secuenciales y obligatorias**. No saltes
ninguna fase ni combines pasos: cada una depende de que la anterior se haya
completado correctamente.

---

## REGLAS GENERALES (aplican a las tres fases)

1. **No especules.** Si no puedes verificar algo leyendo el código del
   proyecto o la documentación oficial descargada, dilo explícitamente en
   vez de inventar una respuesta plausible. Frases como "probablemente",
   "normalmente Android hace X" o "asumo que" están prohibidas salvo que
   vayan seguidas de una verificación real.
2. **Cita la fuente de cada afirmación técnica.** Si dices que una función
   existe, di en qué archivo y línea la viste. Si dices que una API de
   Android se comporta de cierta forma, di en qué documento de
   `tools/context-floating-app/docs/` lo leíste.
3. **Si algo no está cubierto** ni por el código del proyecto ni por la
   documentación descargada, dilo y pregunta antes de improvisar una
   solución.
4. Todo el trabajo debe respetar la arquitectura ya existente: **el
   overlay no implementa lógica de negocio propia**. Reutiliza los
   repositorios, datasources y servicios que ya existen en `lib/` y el
   `MethodChannel`/`EventChannel`/`WorkManager` que ya existen en
   `android/app/src/main/kotlin/mods/sm64cdpy/`.

---

## FASE 1 — Auditoría real del proyecto (sin mencionar el overlay todavía)

Antes de hablar de la nueva funcionalidad, quiero que construyas un mapa
mental **verídico** de cómo está hecha la app hoy. Lee el código, no lo
asumas.

Analiza a profundidad, archivo por archivo, estas dos carpetas completas:

```
lib/
android/app/src/main/kotlin/mods/sm64cdpy/
android/app/src/main/AndroidManifest.xml
android/app/build.gradle.kts
```

Para cada una, documenta lo siguiente basándote únicamente en lo que leas:

### 1.1 Arquitectura Flutter (`lib/`)
- ¿Qué gestor de estado se usa? (revisa `presentation/providers/`)
- ¿Cómo está organizada la capa de datos? (`data/`, `domain/`) — identifica
  el patrón exacto (repository pattern, datasource por fuente, etc.)
- ¿Qué persistencia local se usa? (busca Hive, SharedPreferences, u otros)
- ¿Cómo se enrutan las pantallas? (`core/router/app_router.dart`)
- Lista completa de `services/` y qué hace cada uno, en una frase por
  servicio, basada en el código real, no en el nombre del archivo.

### 1.2 Puente nativo (Android/Kotlin)
- Lista **todos** los `MethodChannel` y `EventChannel` existentes: nombre
  exacto del canal, en qué archivo Kotlin se define, y en qué archivo Dart
  se consume.
- ¿Cómo maneja actualmente `ModInstallerPlugin.kt` el `eventSink`? ¿Soporta
  múltiples listeners simultáneos o es un solo campo nullable? Confírmalo
  leyendo el código, no repitas lo que se te diga aquí sin verificarlo.
- ¿Qué hace `WorkManager` en este proyecto? ¿Qué workers existen
  (`ModDownloadWorker`, `ModInstallWorker`) y cómo reportan progreso hacia
  Dart?
- ¿Qué permisos están declarados en `AndroidManifest.xml` hoy? Lista el
  manifest completo tal como está, sin resumir.
- `minSdk`, `targetSdk`, `compileSdk` y `applicationId` exactos del
  `build.gradle.kts`.

### 1.3 Entregable de esta fase
Un resumen técnico (no una copia del código) que confirme que entendiste
la arquitectura real del proyecto. Si encuentras algo que contradiga lo
que se describe en este mismo prompt más adelante, señálalo.

**No continúes a la Fase 2 hasta terminar esta auditoría.**

---

## FASE 2 — Contexto del objetivo

Ahora que conoces el estado real del proyecto, este es el objetivo:

### Qué se quiere construir

Un **panel flotante estilo "chat heads" de Messenger**, pero para gestión
de mods de *Super Mario 64 Coop Deluxe*. El usuario está jugando (el juego
tiene el foco de pantalla completa) y necesita, sin salir del juego:

- Ver una burbuja flotante pequeña sobre el juego.
- Al tocarla, expandir un panel donde puede buscar mods.
- Pulsar "Download" y que se descargue e instale usando el flujo que ya
  existe (`WorkManager` + `ModInstallerPlugin`), sin reimplementar nada.
- Cerrar el panel y seguir jugando sin interrupciones.

### Decisión de arquitectura ya tomada (no la cuestiones, impleméntala)

**Enfoque híbrido:**
- La **burbuja** (el círculo pequeño y arrastrable que se ve todo el
  tiempo) es una `View` nativa de Android dentro de un `WindowManager`,
  **sin** `FlutterEngine`. Es solo un ícono con `OnTouchListener` para
  arrastrar y detectar tap.
- El **panel expandido** (lo que aparece al tocar la burbuja) sí usa un
  `FlutterEngine` + `FlutterView` embebido en el mismo `Service`, con un
  segundo entrypoint de Dart (`@pragma('vm:entry-point')`), separado del
  `main()` de la app normal.
- Todo corre dentro de un **Foreground Service** (`OverlayService`), no
  dentro de una `Activity`.

### Dos problemas ya detectados que deben resolverse como parte del trabajo

1. El `eventSink` en `ModInstallerPlugin.kt` es un único campo nullable.
   Si el overlay (con su propio `FlutterEngine`, y por tanto su propio
   `EventChannel`) escucha al mismo tiempo que la app principal, uno de
   los dos deja de recibir eventos. Hay que resolver esto antes de
   conectar el overlay a las descargas — ya sea con una colección de
   sinks o con un mecanismo de broadcast a todos los listeners activos.
2. Riverpod (`ProviderScope`) no se comparte entre isolates. El
   `FlutterEngine` del overlay corre en su propio isolate Dart, así que
   necesita su **propio** `ProviderScope`, no puede asumir que ve el
   estado de la app principal. Cualquier dato que sí deba compartirse
   entre ambos (por ejemplo, configuración del usuario) tiene que pasar
   por algo persistente multi-isolate-safe: `SharedPreferences` o Hive,
   no memoria en runtime.

### Estructura de archivos objetivo

```text
android/app/src/main/kotlin/mods/sm64cdpy/overlay/
├── OverlayService.kt        # Foreground Service, ciclo de vida del overlay
├── BubbleView.kt              # Vista nativa arrastrable
├── OverlayPermission.kt        # SYSTEM_ALERT_WINDOW: chequeo y solicitud
├── OverlayFlutterHost.kt        # Crea/destruye FlutterEngine + FlutterView del panel
└── OverlayChannels.kt            # Nombres de canales dedicados al overlay

lib/overlay/
├── overlay_main.dart          # Segundo entrypoint Dart
├── overlay_app.dart            # Widget raíz del panel (ProviderScope propio)
├── overlay_bridge.dart          # MethodChannel hacia OverlayService
└── overlay_panel.dart            # UI: burbuja → búsqueda → resultados
```

### Fases de implementación, en orden

- **Fase 0**: permiso `SYSTEM_ALERT_WINDOW` + burbuja nativa arrastrable
  (sin Flutter todavía).
- **Fase 1**: panel expandido con `FlutterEngine`/`FlutterView` mostrando
  un widget mínimo.
- **Fase 2**: canal de comunicación (`OverlayChannels.kt`) entre el
  Service y el panel Flutter.
- **Fase 3**: reutilizar el buscador de mods existente (requiere resolver
  el problema del `eventSink` primero).
- **Fase 4**: reutilizar descarga/instalación (`ModInstallerPlugin`,
  `WorkManager`) tal cual, sin duplicar lógica.

### Entregable de esta fase

Confirma que entendiste el objetivo y, basándote en lo que auditaste en la
Fase 1, señala cualquier fricción real que veas entre el código actual y
este plan (por ejemplo: nombres de canal que podrían colisionar, código
que asume que solo hay una `Activity` corriendo, etc.). No propongas
código todavía.

**No continúes a la Fase 3 hasta completar esto.**

---

## FASE 3 — Verificación contra documentación oficial (obligatoria antes de codear)

Antes de escribir una sola línea de código de la Fase 0 en adelante, usa
la herramienta de documentación local del proyecto para verificar contra
las fuentes oficiales, en vez de confiar en tu conocimiento entrenado
(que puede estar desactualizado respecto a versiones recientes de
Android).

### Ubicación de la herramienta

```
tools/context-floating-app/
```

### Cómo usarla

```bash
cd tools/context-floating-app

# Ver qué grupos de contexto existen (alineados a las fases del roadmap)
python cli.py groups

# Cargar el contexto oficial de la fase en la que estás trabajando
python cli.py context fase2_ventana_flotante --output /tmp/fase2.md

# Buscar un término específico en toda la documentación ya descargada
python cli.py search "TYPE_APPLICATION_OVERLAY"

# Ver un documento completo
python cli.py show overlay_permission_settings
```

Si algún documento necesario todavía no está descargado, avisa
explícitamente cuál falta y sugiere el comando `python cli.py fetch`
en vez de responder con lo que crees recordar sobre esa API.

### Regla de verificación obligatoria

Antes de afirmar cómo se comporta cualquiera de estas APIs, **confírmalo
leyendo el Markdown correspondiente** dentro de
`tools/context-floating-app/docs/`, no lo asumas de memoria:

- `WindowManager` / `WindowManager.LayoutParams` — tipos de ventana
  (`TYPE_APPLICATION_OVERLAY`), flags, gravity.
- `SYSTEM_ALERT_WINDOW` / `ACTION_MANAGE_OVERLAY_PERMISSION` — cómo
  cambió el flujo de permiso entre versiones de Android.
- `Foreground Services` — especialmente `foregroundServiceType`,
  obligatorio desde Android 14 (API 34), y qué categoría aplica (o si
  hace falta `specialUse`) para un servicio de overlay.
- `MotionEvent` — para el arrastre de la burbuja.
- `Lifecycle` — para manejar correctamente el ciclo de vida del
  `FlutterEngine` embebido cuando el `Service` se destruye o el sistema
  mata el proceso.
- `platform_channels` / `add_to_app` (Flutter) — para el patrón correcto
  de `FlutterEngine`/`FlutterView` fuera de una `Activity`.

Si la documentación descargada no cubre un detalle específico que
necesitas (por ejemplo, un caso límite de un fabricante concreto de
Android), dilo explícitamente y trátalo como una suposición sin verificar,
claramente marcada como tal — nunca la presentes con el mismo nivel de
confianza que algo que sí verificaste.

### Entregable final

Solo después de completar las tres fases, entrega un plan de
implementación de la **Fase 0** (permiso + burbuja nativa) archivo por
archivo, indicando para cada afirmación técnica si viene de:
- el código auditado en la Fase 1 (cita archivo),
- la documentación oficial verificada en la Fase 3 (cita el nombre del
  documento en `docs/`), o
- una suposición sin verificar (márcala explícitamente como tal).

No escribas código de fases posteriores a la Fase 0 hasta que esta esté
validada.
