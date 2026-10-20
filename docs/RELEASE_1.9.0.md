# SM64CDPY 1.9.0 — preparación de release

Candidata preparada en la rama `how-to-play-guide`: **1.9.0+28**. Esta
preparación no crea tag, no publica una release y no sustituye la validación
física en Android. El merge a `main` y la ejecución de Testing quedan a cargo
del propietario.

## Alcance

- Preparador local de ROM accesible desde Cómo jugar y GameTool.
- Detección por cabecera de `.z64`, `.v64` y `.n64`; salida `.z64` validada para
  la versión Android de SM64CoopDX estudiada.
- Transformación nativa por bloques, staging privado aislado por operación,
  exportación SAF y verificación de tamaño/MD5. El archivo original permanece
  en solo lectura y la app no descarga, incluye ni comparte ROMs.
- Estados de progreso, cancelación, reintento y errores accionables; `prepared`
  y `saved` se muestran como resultados distintos.
- Retro Manga completa su sistema de superficies: borde de tinta, sombra dura y
  geometría rectangular en tarjetas, paneles, ROM, Save Files, drawer, ajustes,
  diálogos, campos, menús, chips, botones, switches, sliders, progreso, pestañas,
  `ExpansionTile` y tooltips.
- Encabezados de sección inclinados con `displayLabel`, truncado controlado en
  pantallas estrechas y conservación de la identidad manga.
- Optimizaciones menores de composición y política de tema: se retiran overrides
  locales, no se añaden blur, shaders ni recursos raster y la trama de semitono
  permanece aislada en `RepaintBoundary`.
- Los otros cinco diseños y el overlay conservan sus tratamientos. La
  desinstalación segura del roadmap no forma parte de esta candidata.

## Distribución

| Campo | Valor |
|---|---|
| versionName / build | 1.9.0 / 28 |
| VersionCode arm32 / arm64 / x86_64 | 281 / 282 / 283 |
| Tag previsto | v1.9.0 (sin crear) |
| Manifiesto | release-manifests/v1.9.0.json |
| Actualización obligatoria | No |
| Toolchain | Flutter 3.41.7, Dart 3.11.x, Java 17 |
| Android mínimo | API 24 |

Conservar `Sm64CDPY-arm64.apk`, `Sm64CDPY-arm32.apk` y
`Sm64CDPY-x86_64.apk`. El manifiesto es la autoridad para GitHub Releases,
Discord y la sincronización del sitio web. Los previews
`RELEASE_NOTES_1.9.0_EN/ES/PT_BR.md` se generan desde ese manifiesto.
`publishedAt` es provisional y debe actualizarse al momento real de publicación.

## Validación local

- `flutter analyze lib`: sin errores; conserva avisos informativos preexistentes
  de llaves en sentencias `if`.
- `flutter test`: **280 pruebas aprobadas**, incluidas las suites de los seis
  temas, ROM a 320/360 px con texto ampliado, guía, ajustes, Save Files, detalle,
  selector de idioma y aislamiento de Retro Manga.
- `python3 scripts/release_manifest.py release-manifests/v1.9.0.json --pubspec pubspec.yaml`:
  manifiesto válido y sincronizado con `pubspec.yaml`.
- Pruebas Python del contrato de release: aprobadas.
- `dart format` aplicado y `git diff --check` limpio.
- No se modificó el overlay ni se añadieron dependencias, permisos generales de
  almacenamiento o recursos nuevos.

## Puerta pendiente

- Fusionar `how-to-play-guide` en `main` sin crear el tag todavía.
- Ejecutar Testing en `main` y descargar el APK arm64 firmado.
- Probar con proveedores SAF locales, remotos y lentos; rotación, poca memoria,
  poco espacio, cancelación durante conversión/exportación y exportación
  verificada.
- Probar con una ROM propia: z64, v64 y n64; confirmar MD5 de salida, que el
  original siga intacto y que el juego acepte la copia exportada.
- Revisar Retro Manga en claro/oscuro, 320/360 px y texto ampliado: ROM, Save
  Files, diálogos, botones deshabilitados, drawer y ajustes.
- Confirmar `publishedAt`, crear `v1.9.0` y ejecutar el workflow oficial solo con
  autorización explícita. La desinstalación segura queda para una fase posterior.
