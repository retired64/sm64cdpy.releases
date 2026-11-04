# SM64CDPY 1.9.2 — preparación de release

Candidata local en `main`: **1.9.2+30**. Última release pública comprobada con
GitHub CLI: **v1.9.1**, publicada el 2026-10-26 UTC. No se crea tag ni se publica
una release con esta preparación.

## Integración y alcance

- Base local/remota `main`: `07fc041`.
- Rama integrada: `r2-phase6-flutter-fallback`, `f616663`.
- Ambas ramas coincidían con sus referencias `origin` después de fetch.
- Merge explícito con historial conservado, sin conflictos de Git.
- El alcance de la candidata también incluye los cambios de main posteriores a
  v1.9.1, como compatibilidad con metadata enriquecida y mantenimiento documental.

### Descargas y catálogo

R2 es respaldo opcional cuando el catálogo contiene un mirror válido. Ajustes
permite preferirlo, conservando la otra fuente válida como fallback. La misma
resolución se aplica en app, descarga manual y overlay. El cambio de fuente no
cambia identidad del artefacto, UUID de operación o cadena de instalación.

Se conserva compatibilidad con catálogos sin campos de mirror y metadata
opcional de artefactos. La versión no convierte R2 en fuente única ni introduce
el contrato SQLite del explorador Kotlin: este es el producto Flutter.

### Activación del juego

Encabezados Lua largos siguen el truncado del juego; los scripts desactivados
ilegibles no bloquean unidades ajenas. Se explican motivos concretos y se
recalculan switches hermanos después de una escritura confirmada. La selección
para el siguiente inicio conserva las verificaciones de incompatibilidad y la
confirmación de juego cerrado del flujo existente.

### Jugador

Los cinco personajes tienen jerarquía articulada y reposo derivado de la ROM.
El visor sigue siendo JavaScript/Three.js local en WebView, no un renderizador
Kotlin o C++ completamente nativo. La superficie AndroidView estable evita
redimensionados repetidos al deslizar lentamente; se conservan gestos y editor.

Ambos workflows prueban el motor JavaScript y verifican HTML y módulos anidados
dentro del APK final antes de distribuir artifacts. No se incluyen ROM ni assets
extraídos del usuario en Git o APK.

## Versión y distribución

| Campo | Valor |
|---|---|
| versionName | 1.9.2 |
| Build de Flutter | 30 |
| VersionCode arm32 / arm64 / x86_64 | 301 / 302 / 303 |
| Fuente de versión | pubspec.yaml |
| Manifiesto | release-manifests/v1.9.2.json |
| Tag previsto, todavía sin crear | v1.9.2 |
| Actualización forzada | No |
| Android mínimo | API 24, sin cambio |
| Paquete y firma | Configuración existente, sin cambio |

Los APK conservan `Sm64CDPY-arm64.apk`, `Sm64CDPY-arm32.apk` y
`Sm64CDPY-x86_64.apk`. Los códigos se calculan con la regla existente
`build * 10 + ABI`; no usar 30 como código final de los APK split.

Manifiesto canónico EN/ES/PT-BR para GitHub Releases, Discord y sitio web.
Las notas `RELEASE_NOTES_1.9.2_*` se generan con `scripts/release_manifest.py`;
no mantener copias manuales divergentes. `publishedAt` es provisional, no la
fecha de una publicación realizada. Confirmarlo antes del workflow de release.

Los workflows ya leen pubspec y validan el manifiesto correspondiente. No
necesitan fijar otra versión en YAML. El toolchain permanece Flutter 3.41.7,
Dart 3.11.x y Java 17. No se cambian claves ni secretos.

## Validación y límites

La rama fuente f616663 tiene [Testing #41750366552 exitoso](https://github.com/retired64/sm64cdpy.releases/actions/runs/41750366552).
Ese resultado pertenece al SHA fuente, no al commit final de merge/versionado.
No presentar su APK como una compilación de 1.9.2+30.

En este Termux no están disponibles Flutter/Dart en PATH ni `android/gradlew`.
Por ello generación l10n, `flutter analyze lib`, `flutter test` y compilación
Kotlin no se ejecutan localmente. El merge conserva los archivos generados y
ambos workflows tienen generación/análisis/tests configurados. No se modifica
Dart generado manualmente para simular esa validación.

Comprobaciones locales ejecutadas sobre el árbol fusionado y versionado:

- `scripts/release_manifest.py` valida 1.9.2+30 y genera las notas EN/ES/PT-BR.
- `python -m unittest discover -s test/scripts -p '*_test.py' -v`: 19 pruebas
  aprobadas, incluidas localización, manifiestos, NDK y grafo empaquetado sintético.
- `env LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib node --test test/player3d/*.test.mjs`:
  19 aprobadas, 0 fallos y 1 omitida por no proporcionar ROM/ELF privados.
  El LD_LIBRARY_PATH explícito evita una incompatibilidad del entorno al lanzar Node.
- `python scripts/check_doc_links.py`: 83 documentos con enlaces locales válidos.
- `git diff --check` y revisión del diff staged: sin errores de espacios.

No se generó un APK nuevo, no se ejecutó la suite Flutter local y no se repitieron
pruebas físicas. Las pruebas de assets de Python usan fixtures sintéticos; no
certifican un APK 1.9.2 real todavía inexistente.

## Puerta de testing y publicación

1. Revisar y subir el merge a main cuando se autorice el push.
2. Ejecutar `buildAndroid-testing.yml` sobre main; `all_abis: true` permite
   validar las tres arquitecturas sin publicar.
3. Confirmar versión y firma del APK nuevo, notas, módulos del visor y artifacts.
4. Probar descargas por ambas preferencias, catálogo sin mirror, red/fallback,
   cancelación y recepción de progreso desde app/overlay.
5. Probar activación con encabezados largos, scripts ilegibles, incompatibilidades
   reales, permiso revocado, refresco y selección persistida al reabrir.
6. Probar los cinco personajes, scroll lento/rápido, giro, cambios rápidos de perfil,
   navegación, pausa/reanudación, rotación y ambos modos visuales pertinentes.
7. Revisar OTA por ABI, confirmar fecha y ejecutar publicación solo con
   autorización explícita. No crear manualmente un tag antes de que el workflow
   compruebe su ausencia.

Este trabajo no ejecuta workflow de publicación, avisos Discord o dispatch web,
ni afirma que la matriz física del merge final esté aprobada.
