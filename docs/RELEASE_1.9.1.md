# SM64CDPY 1.9.1 — preparación de release

Candidata integrada en `main`: **1.9.1+29**, tomando `v1.9.0` como base. Este
documento no crea el tag ni publica la release.

Es un parche centrado en navegación. No cambia descargas, instalación, SAF,
overlay, catálogo, idiomas ni el contrato de actualización.

## Alcance

### Navegación fluida

- Un solo historial en memoria para los destinos principales (Inicio, Catálogo,
  Popular, Favoritos, Biblioteca, Jugador, Jugar, Partidas, Preparar ROM,
  Ajustes, Cómo jugar y colecciones), limitado a 20 entradas, con query strings
  conservados, identidad por `uri.path` y sin duplicados consecutivos.
- Atrás sigue un orden explícito: cerrar drawer, diálogo, modal o submenú;
  hacer pop de una pantalla secundaria; volver al destino principal anterior;
  volver a Inicio; y permitir la salida solo desde Inicio sin historial.
- `AppNavigator` es la única fuente del historial y del guard de Jugador.
  `AppShell` lo expone mediante `AppNavigationScope`, de modo que drawer, dock
  Retro Manga, enlaces internos y flecha visual comparten la misma política.
  GoRouter sigue siendo la autoridad de la ubicación activa y
  `currentRouteProvider` es solo una proyección para resaltar el menú.
- Encabezados coherentes: hamburguesa en destinos principales clásicos, sin
  leading en Manga/Deluxe y flecha temática en secundarias, incluida Permisos.
- Jugador conserva `PopScope` y el diálogo localizado de descarte; el retroceso
  confirmado pasa por `AppNavigator` y ya no por `maybePop`.

### Navegación guiada de permisos

- Nueva pantalla **Permisos y accesos** en Ajustes (`/settings/permissions`,
  hija de `/settings`), con tarjetas para carpeta del juego, notificaciones,
  acceso a todos los archivos cuando el dispositivo lo soporta, burbuja
  flotante y optimización de batería.
- `PermissionAccessService` lee el estado real de Android en cada visita y al
  reanudar la app; la UI muestra permitido, no permitido u opcional, bloquea
  acciones simultáneas y nunca guarda una copia del permiso.
- Flujo guiado de cuatro pasos (Bienvenido, carpeta del juego, instalación
  automática y todo listo) que aparece una vez en el primer inicio y puede
  repetirse desde el centro de permisos.
- `GuidedSetupService` guarda únicamente el progreso educativo en Hive
  (`guided_setup_v1`); Android y SAF siguen siendo la autoridad de cada
  capacidad.
- Las notificaciones se solicitan en el momento de iniciar una operación en
  segundo plano; una negativa no bloquea la descarga ni la instalación.

## Distribución

| Campo | Valor |
|---|---|
| versionName / build | 1.9.1 / 29 |
| VersionCode arm32 / arm64 / x86_64 | 291 / 292 / 293 |
| Base comparada | v1.9.0 |
| Tag previsto | v1.9.1 (sin crear) |
| Manifiesto | release-manifests/v1.9.1.json |
| Actualización obligatoria | No |
| Android mínimo | API 24 |

Conservar `Sm64CDPY-arm64.apk`, `Sm64CDPY-arm32.apk` y
`Sm64CDPY-x86_64.apk`. El manifiesto es la autoridad para GitHub Releases,
Discord y la sincronización del sitio web. `publishedAt` queda provisional y
debe confirmarse el día de la publicación.

## Validación completada

- `flutter analyze lib`: sin problemas.
- `flutter test`: **543 pruebas aprobadas**.
- `python3 scripts/release_manifest.py release-manifests/v1.9.1.json --pubspec pubspec.yaml`:
  manifiesto válido y alineado con `pubspec.yaml`.
- `git diff --check`: limpio.
- La lógica fue verificada por el usuario en dispositivo antes de preparar esta
  versión.

## Puerta previa a la publicación

- Ejecutar Testing en `main` y revisar el APK arm64 firmado en un dispositivo
  físico de pocos recursos.
- Matriz manual de Atrás: desde cada destino principal, con drawer abierto, con
  diálogo o modal, en Jugador con cambios sin guardar, tras rotar y tras
  reabrir la app; comprobar que la salida solo ocurre desde Inicio sin
  historial.
- Matriz manual de permisos: conceder y revocar notificaciones, burbuja,
  todos los archivos y batería; revocar mientras la app está en segundo plano y
  volver a comprobar al reanudar; Android 13+ con notificaciones denegadas;
  carpeta SAF revocada; repetir el recorrido guiado desde Ajustes.
- Confirmar `publishedAt`, crear `v1.9.1` y lanzar el workflow oficial solo con
  autorización explícita.

## Exclusiones conocidas

- Sin cambios en descargas, instalación, SAF, biblioteca, overlay, catálogo ni
  idiomas respecto a 1.9.0.
- El idioma de la burbuja flotante sigue sin cambiar.
- La desinstalación segura del roadmap continúa fuera de esta versión.
