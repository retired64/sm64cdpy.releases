# SM64CDPY 1.8.8 — preparación de release

Candidata integrada en `main`: **1.8.8+27**. Esta preparación no crea tag,
no publica una release y no sustituye la validación física en Android.

## Alcance

- Overhaul visual de Minish Cap con papel, letreros y tarjetas de madera
  consistentes, sin blur ni recortes costosos.
- Mario Kart 64 compatible con los ocho acentos de interfaz y contraste
  verificado en modos claro y oscuro.
- Renderizado ligero en drawer, detalle, superficies compartidas y Jugador;
  área segura global para barra de estado y recortes de pantalla.
- Instalación directa opcional en almacenamiento principal mediante el permiso
  de Android para administrar todos los archivos; SAF continúa como fallback.
- Extracción ZIP/7z/archivo suelto con paralelismo acotado, cancelación,
  validación de rutas, rollback, recibos e invalidación de descubrimiento.

## Distribución

| Campo | Valor |
|---|---|
| versionName / build | 1.8.8 / 27 |
| VersionCode arm32 / arm64 / x86_64 | 271 / 272 / 273 |
| Tag previsto | v1.8.8 (sin crear) |
| Manifiesto | release-manifests/v1.8.8.json |
| Actualización obligatoria | No |
| Toolchain | Flutter 3.41.7, Dart 3.11.x, Java 17 |

Conservar `Sm64CDPY-arm64.apk`, `Sm64CDPY-arm32.apk` y
`Sm64CDPY-x86_64.apk`. `publishedAt` es provisional y debe actualizarse al
momento real de publicación.

## Validación local

- Manifiesto validado contra `pubspec.yaml`; previews EN/ES/PT-BR preparados.
- `flutter analyze lib --no-fatal-infos`: sin errores; conserva avisos
  informativos preexistentes de llaves en sentencias `if`.
- Pruebas Flutter de temas, acentos, detalle y persistencia de Jugador: 65/65.
- Pruebas Python del contrato de release: 4/4.
- Pruebas Kotlin de rutas directas, journal/rollback y cancelación paralela:
  correctas mediante `:app:testDebugUnitTest`.
- APK debug compilado correctamente; los daemons de Gradle se detienen al
  terminar esta preparación.

## Puerta pendiente

- Probar físicamente permiso concedido/revocado, fallback SAF, ZIP, 7z,
  archivo suelto, cancelación y refresco de Biblioteca.
- Probar Minish Cap y Mario Kart 64 en claro/oscuro y dispositivo de gama baja.
- Ejecutar Testing en `main`; publicar solo mediante autorización explícita.
