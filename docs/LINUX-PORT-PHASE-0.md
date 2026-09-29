# Linux Port — Fase 0: baseline, inventario y contratos

> Evidencia de la investigación realizada antes de modificar el flujo
> productivo de Android o habilitar instalaciones reales en Linux.

| Campo | Resultado |
|---|---|
| Fecha | 2026-09-28 |
| Rama | `linux-port` |
| Commit base | `252ef2e` — release Android 1.8.2 |
| Estado de la fase | Completa |
| Código productivo conectado | No; los contratos todavía no sustituyen el backend Android |

## 1. Conclusión ejecutiva

El proyecto ya contiene un runner Linux válido y compila un bundle debug. El
bloqueo inicial no está en CMake, GTK ni el catálogo: ocurre en runtime porque
el bootstrap común inicializa el EventChannel de WorkManager y la proyección de
Biblioteca intenta leer un MethodChannel implementado únicamente por Android.

La ejecución controlada produjo estas dos evidencias principales:

```text
MissingPluginException(No implementation found for method listen on channel
mods.sm64cdpy/mod_install_events)

MissingPluginException(No implementation found for method
getInstallationLibrary on channel mods.sm64cdpy/mod_installer)
```

Por ello, la Fase 1 no necesita rehacer el runner. Debe separar el bootstrap por
plataforma y registrar temporalmente un backend Linux de solo lectura, mientras
Android conserva exactamente su MethodChannel, EventChannel y WorkManager.

## 2. Baseline reproducible

### Entorno observado

```text
Sistema: Fedora Linux 44 x86_64
Flutter: 3.41.6 stable
Dart: 3.11.4
Java: Temurin 17.0.10
Android SDK: 36.1
CMake: 4.3.0
Ninja: 1.13.2
GTK: 3.24.52
```

La carpeta del SDK se llama `/home/mikky/flutter/3.38.7`, pero el binario que
contiene reporta Flutter 3.41.6. El nombre del directorio no se considerará una
fuente confiable de versión.

La documentación del proyecto menciona Flutter 3.41.7. No se actualizó ni
degradó el SDK durante esta fase: la diferencia queda registrada para decidir
si se alinea antes del CI Linux.

`flutter doctor -v` confirmó:

- toolchain Android disponible;
- toolchain Linux disponible;
- dispositivo Linux detectado;
- licencias Android aceptadas;
- red accesible;
- advertencia no bloqueante al consultar información EGL.

### Validaciones ejecutadas

| Comando | Resultado |
|---|---|
| `flutter pub get` | Correcto; plugins regenerados |
| `flutter analyze lib` | Sin incidencias |
| `flutter test` | 44 pruebas aprobadas antes de añadir contratos |
| `flutter build linux --debug` | Correcto |
| Ejecución controlada del bundle Linux | Abre; detecta canales Android ausentes |
| `flutter build apk --debug` | Correcto |
| Tests nuevos de contratos | 4 pruebas aprobadas |

Los tamaños debug observados no son objetivos de distribución:

```text
Bundle Linux debug: aproximadamente 181 MiB
APK Android debug: aproximadamente 161 MiB
```

No se usarán para evaluar el tamaño final hasta generar builds release.

## 3. Plugins Linux generados

El registro nativo generado para Linux contiene solamente:

```text
Plugin GTK: url_launcher_linux
Plugin FFI: jni
```

Otros paquetes compatibles con Linux usan implementaciones Dart/FFI y por ello
no necesariamente aparecen como plugins GTK. Los archivos generados no se
editarán manualmente.

### Clasificación inicial

| Dependencia | Clasificación | Decisión para el port |
|---|---|---|
| `floaty_chatheads` | Aislable Android | No importar/inicializar en el bootstrap Linux; overlay fuera del MVP |
| `ota_update` | Aislable Android | Mantener para APK; Linux no ofrece OTA APK |
| `flutter_file_downloader` | Reemplazable | Conservar en Android y sustituir por el backend Linux controlado |
| `file_picker` | Compatible, por validar | Usar únicamente después de probar selección de directorios real |
| `path_provider` | Compatible | Solo para almacenamiento propio de SM64CDPY, no para localizar el juego |
| `shared_preferences` | Compatible | Preferencias ligeras; no autoridad de archivos instalados |
| `hive_flutter` | Compatible, por validar | Proyección y ajustes; requiere prueba de persistencia real |
| `device_info_plus` | Compatible | Usar solo si una capacidad Linux lo necesita |
| `package_info_plus` | Compatible | Permite mostrar versión del binario Linux |
| `share_plus` | Compatible mediante URL launcher | Verificar UX de escritorio antes de exponer |
| `url_launcher` | Compatible | Ya se registra `url_launcher_linux` |
| `cached_network_image`/`flutter_cache_manager` | Riesgo | Investigar almacenamiento SQLite en Linux durante Fase 1 |
| `sqflite` | No tiene implementación Linux vigente en este grafo | No depender de él como persistencia Linux sin backend explícito |
| `jni` | Indirecta, no bloqueante | El build la incluye por el grafo de `path_provider_android`; investigar antes de limpiar |

El build exitoso demuestra compatibilidad de compilación, no que cada método de
cada paquete esté implementado en Linux.

## 4. Inventario de acoplamientos Android

### Bootstrap

`lib/main.dart` inicializa sin composición por plataforma:

- configuración de `flutter_file_downloader`;
- `UpdateService` orientado a GitHub Releases/APK;
- `BackgroundInstallService` y su EventChannel;
- `InstallationLibraryProjectionService`, cuyo gateway es MethodChannel;
- `OverlayBridge` y `floaty_chatheads`.

La primera separación de Fase 1 debe ocurrir aquí. Capturar
`MissingPluginException` no sería una solución: ocultaría capacidades rotas y
mantendría una arquitectura falsa.

### Instalación y carpetas

Las llamadas directas a `ModInstaller` aparecen en:

- repositorio de Biblioteca;
- bridge del overlay;
- Ajustes;
- detalle general;
- VIP;
- DynOS;
- Touch Controls;
- OMM;
- servicio de operaciones en background.

El servicio actual expone conceptos Android concretos:

- URI SAF;
- permisos de notificación Android;
- UUID de WorkManager;
- reconciliación de Workers;
- métodos de picker del plugin Kotlin.

Estas funciones se adaptarán detrás del contrato, no se copiarán a un servicio
Linux con nombres engañosos.

### Estado de operaciones

`BackgroundInstallService` es leído directamente por:

- providers de progreso;
- provider de Biblioteca;
- coordinador/presentación de acciones;
- detalles y secciones de catálogo;
- proyección de Biblioteca;
- overlay y bridge.

La Fase 3 migrará esos consumidores a una abstracción compartida. Durante la
Fase 1 se registrará un backend Linux de solo lectura para evitar acciones
falsas sin refactorizar prematuramente todo el flujo.

### Descarga manual

`FileDownloader` se utiliza directamente en detalle, VIP, DynOS, Touch
Controls y OMM. Estas implementaciones hermanas deben migrarse juntas cuando se
introduzca el backend Linux; corregir solo Detalle volvería incoherentes las
demás superficies.

### Overlay

`floaty_chatheads` aparece en:

- entrada secundaria `overlayMain`;
- `OverlayBridge`;
- panel flotante;
- Ajustes.

Linux no registrará ni mostrará estas funciones en el MVP. El overlay Android
seguirá compilándose y su contrato de identidad no se elimina.

### OTA y lanzamiento del juego

- `UpdateDialog` protege la instalación OTA con plataforma Android, pero
  `UpdateService.init()` se ejecuta en el bootstrap Linux y debe separarse.
- `GameLauncherService` ya devuelve `false` fuera de Android; posteriormente
  se sustituirá por una capacidad Linux explícita si se aprueba esa función.

## 5. Fuentes de estado y persistencia actuales

### Android

| Dato | Escritor | Lectores | Autoridad |
|---|---|---|---|
| Operación activa | WorkManager/Kotlin | EventChannel y reconciliación | WorkManager |
| Carpeta Mods/DynOS | Plugin Kotlin | Workers, verificador y scanner | SharedPreferences nativa + permiso SAF |
| Metadata activa | Flutter | `BackgroundInstallService` | Proyección recuperable de WorkManager |
| Recibos | `ModInstallWorker` | Plugin/repositorio Flutter | Archivos privados nativos |
| Presencia | Verificador SAF | Biblioteca | Árbol SAF |
| Proyección | Repositorio Flutter | Riverpod/UI | Cache Hive, no autoridad |
| Favoritos | Flutter | providers y overlay indirecto | SharedPreferences |
| Tema/locale | Flutter | UI y réplica overlay | Hive + réplica controlada |

### Linux aprobado para implementación posterior

| Dato | Ubicación lógica | Autoridad |
|---|---|---|
| Descarga y staging | `$XDG_CACHE_HOME/sm64cdpy/operations` | Archivos temporales por operación |
| Diario de recuperación | `$XDG_STATE_HOME/sm64cdpy/operations` | Journal atómico |
| Recibos e historial | `$XDG_DATA_HOME/sm64cdpy/installations` | Recibos portables atómicos |
| Ajustes/proyección | Implementación desktop de preferencias/Hive | Cache/configuración, no presencia |
| Presencia instalada | Raíz de SM64CoopDX | Filesystem |

Fallbacks cuando las variables XDG no existan:

```text
XDG_CACHE_HOME → $HOME/.cache
XDG_STATE_HOME → $HOME/.local/state
XDG_DATA_HOME  → $HOME/.local/share
```

Los datos privados de SM64CDPY no se guardarán dentro de
`~/.local/share/sm64coopdx`. Esa ruta pertenece al juego y contendrá únicamente
los mods/packs que el usuario espera que el juego lea.

## 6. Contratos creados

### `PlatformCapabilities`

Declara capacidades observables, no el nombre del sistema operativo. Incluye
SAF, XDG, instalación automática, background del SO, supervivencia al proceso,
overlay, OTA APK, apertura de carpetas y notificaciones.

La matriz inicial define:

- Android con SAF, WorkManager, overlay, OTA APK y notificaciones;
- Linux MVP con XDG, instalación automática y apertura de carpetas, pero sin
  prometer background del SO, supervivencia al cierre, overlay u OTA APK.

### `InstallationBackend`

Fija el límite portable para:

- aceptar una solicitud;
- emitir estados ordenados;
- cancelar esperando un terminal confirmado;
- reconciliar operaciones no terminales.

La máquina de estados común contiene:

```text
requested → pending → downloading → installing
          → completed | failed | cancelling → cancelled
```

El contrato utiliza `InstallIdentity` vigente y destinos lógicos `mods` o
`dynos`. No expone URI SAF, `WorkRequest`, `DocumentFile`, tags ni APIs Linux.

### `GameInstallationLocator`

Separa la ubicación del juego de `path_provider`. Devuelve raíz, destino Mods,
destino DynOS, origen de la selección y estado de validez. Admite detección,
override manual y restablecimiento automático.

### Qué todavía no se hizo

- El backend Android no implementa aún el nuevo contrato.
- No existe todavía un backend Linux productivo.
- Ningún provider o widget fue conectado a estos archivos.
- No se modificó Kotlin, WorkManager, SAF ni el overlay.

Esta separación es intencional: los contratos se prueban antes de iniciar el
refactor de Fase 3, mientras la Fase 1 puede concentrarse en un shell Linux de
solo lectura.

## 7. Pruebas de contrato

Se añadió un backend falso que demuestra:

- secuencia completa pending, downloading, installing y completed;
- cancelación que no resuelve hasta obtener `cancelled` terminal;
- reconciliación limitada a operaciones activas;
- capacidades Linux que no prometen funciones Android.

Estas pruebas no certifican todavía el backend Android ni Linux. Funcionan como
especificación ejecutable para sus futuras implementaciones.

## 8. Riesgos confirmados para Fase 1

1. El EventChannel Android se escucha incondicionalmente.
2. Biblioteca se sincroniza mediante MethodChannel durante bootstrap.
3. `OverlayBridge` se inicializa aunque Linux no tenga overlay.
4. OTA consulta versión/release aunque Linux no pueda instalar APK.
5. Descargas manuales están duplicadas en varias pantallas.
6. El cache de imágenes puede depender de SQLite sin backend Linux.
7. La interfaz todavía expone ajustes y acciones móviles.
8. Compilar no garantiza que favoritos/Hive/picker persistan correctamente.
9. Los SVG actuales generan avisos por elementos de animación no soportados;
   no bloquean el port, pero deben distinguirse de fallos de plataforma.
10. El aviso GTK/ATK observado depende del entorno de ejecución automatizado y
    debe reevaluarse en una sesión de escritorio normal.

## 9. Orden exacto de la Fase 1

1. Crear composición de bootstrap común/Android/Linux.
2. Registrar capacidades como dependencia observable.
3. Evitar inicializar downloader Android, OTA, EventChannel, Biblioteca nativa
   y overlay en Linux.
4. Proporcionar Biblioteca Linux vacía/solo lectura con estado explícito, sin
   capturar silenciosamente `MissingPluginException`.
5. Ocultar acciones no disponibles mediante capacidades.
6. Probar catálogo local/remoto, favoritos, temas e idiomas.
7. Investigar el cache de imágenes y sustituir su almacenamiento si falla.
8. Ejecutar runtime Linux sin excepciones de plugins.
9. Repetir análisis, tests, build Linux y build Android.

## 10. Criterio de cierre de Fase 0

- [x] Toolchain y dispositivos registrados.
- [x] Plugins regenerados mediante `flutter pub get`.
- [x] Build y runtime Linux comprobados por separado.
- [x] Baseline Android verde.
- [x] Call sites e implementaciones hermanas inventariados.
- [x] Lectores, escritores y autoridades de estado documentados.
- [x] Contratos portables creados sin conectarlos a producción.
- [x] Backend falso y pruebas de contrato aprobados.
- [x] Almacenamiento privado Linux decidido conceptualmente.
- [x] Riesgos y orden de la siguiente fase registrados.
