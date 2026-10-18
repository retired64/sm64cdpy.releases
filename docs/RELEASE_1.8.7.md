# SM64CDPY 1.8.7 — preparación de release

Candidata integrada en main: **1.8.7+26**. No se crea tag ni se publica una release
como parte de esta preparación.

## Cambios

- Minish Cap: papel cálido, verdes y ocres, fuentes propias para títulos/cuerpo,
  variantes claras/oscuras y superficies ligeras.
- Mario Kart 64: paneles de carreras, cuadros y fuente de títulos propia;
  variantes claras/oscuras con composición nativa.
- Retro Manga: selector expandible de ocho acentos en Ajustes, persistencia Hive,
  cian original como fallback y texto de acento ajustado para contraste.
- Cambiar de diseño o brillo conserva el acento; otros temas y overlay mantienen
  sus paletas. Los colores semánticos siguen siendo independientes.

- GameTool → Save File: gestor de partidas originales con copias independientes,
  progreso editable y respaldos completos antes de cada escritura verificada.

## Distribución

| Campo | Valor |
|---|---|
| versionName / build | 1.8.7 / 26 |
| VersionCode arm32 / arm64 / x86_64 | 261 / 262 / 263 |
| Tag previsto | v1.8.7 (sin crear) |
| Manifiesto | release-manifests/v1.8.7.json |
| Actualización obligatoria | No |
| Toolchain | Flutter 3.41.7, Dart 3.11.x, Java 17 |

Conservar Sm64CDPY-arm64.apk, Sm64CDPY-arm32.apk y Sm64CDPY-x86_64.apk.
El manifiesto es autoridad para las notas de GitHub, Discord y la sincronización
del sitio web. Los previews RELEASE_NOTES_1.8.7_EN/ES/PT_BR.md se generan desde
él; no mantener textos de distribución independientes. publishedAt es provisional
(2026-10-18 UTC): actualizarlo si cambia la fecha real de publicación.

## Validación y salida

- Testing 39142810984 correcto para da7c12f; prueba física de acentos confirmada
  por el usuario. Esto no sustituye validar el commit final 1.8.7.
- Validar manifiesto contra pubspec y ejecutar tests Python del contrato.
- Ejecutar Testing en main antes de la publicación oficial.
- Revisar ambos modos de Minish Cap y MK64, los ocho acentos, texto ampliado,
  reapertura y cambio entre temas en un dispositivo Android.
- Publicación mediante ejecución manual de Build & Release; confirmar firma,
  las tres ABI y fecha del manifiesto. No publicar durante esta preparación.
