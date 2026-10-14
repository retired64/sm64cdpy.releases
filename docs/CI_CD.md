# GitHub Actions y releases

Revisado el 2026-09-28.

> **Fuente canónica:** la aplicación ya no incluye una pantalla de changelog ni
> muestra el cuerpo del GitHub Release. Cada lanzamiento tiene un manifiesto
> localizado en `release-manifests/v<version>.json`. GitHub Releases, Discord y
> el sitio Astro consumen ese mismo documento; Flutter solo conserva la
> detección OTA y de actualización forzada.

## Workflows actuales

### `buildAndroid-testing.yml`

- Se ejecuta manualmente o con un push cuyo mensaje contiene `[testing]`.
- Instala Java 17 y Flutter 3.41.7.
- Genera traducciones (`flutter gen-l10n`), formatea Dart en el runner y guarda
  un parche `flutter-source-sync` para desarrollo Termux sin SDK.
- Firma el APK con secretos, ejecuta `flutter analyze`, conserva el log y ejecuta
  `flutter test --reporter expanded` antes de compilar; conserva `flutter-test-log`
  incluso cuando una prueba falla, y el fallo continúa bloqueando el APK.
- Compila arm64 por defecto; testing manual con `all_abis: true` incluye
  arm32/x86_64 sin publicar releases. Conserva el artifact durante 7 días.
- No crea tag ni GitHub Release.

### `buildAndroid.yaml`

- Solo se ejecuta manualmente y permite marcar una prerelease.
- Release estable requiere `main`; el tag se fija al SHA compilado.
- Lee `versionName`/`versionCode` de `pubspec.yaml`.
- Verifica que no exista el tag `v<versionName>`.
- Genera traducciones, formatea Dart en el runner, ejecuta análisis, compila
  arm64/arm32/x86_64 y guarda un artifact temporal.
- Exige que `release-manifests/v<version>.json` sea válido y coincida
  exactamente con `versionName` y `versionCode`; no publica notas genéricas.
- Ejecuta `flutter test`, renombra APK, calcula SHA-256 y publica las notas en
  inglés generadas desde el manifiesto.
- Notifica releases estables por Discord usando la variante española.
- Para releases estables envía `repository_dispatch` al sitio Astro, que genera
  EN/ES/PT-BR y abre un PR de actualización.

## Secretos necesarios

- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `DISCORD_WEBHOOK_URL` (solo notificación estable)
- `WEBSITE_DISPATCH_TOKEN` (solo release estable): token de acceso limitado al
  repositorio `retired64/sm64cdpy.website`, con permiso **Contents: Read and
  write**. Se usa para verificar acceso y enviar `repository_dispatch`.

`GITHUB_TOKEN` lo proporciona GitHub Actions con permiso `contents: write` en el workflow de release.

## Observaciones de auditoría

- Los workflows están alineados con Java 17 y Flutter 3.41.7. Las releases
  nuevas publican `Sm64CDPY-arm64.apk`, `Sm64CDPY-arm32.apk` y
  `Sm64CDPY-x86_64.apk`; el tag conserva la versión. La OTA acepta además los
  nombres versionados históricos, pero nunca selecciona otra ABI como fallback.
- La suite de tests se ejecuta antes del build y publicación.
- Si el tag ya existe, el workflow indica correctamente que hay que incrementar
  `versionName` y `versionCode`; cambiar solo el build no crea un tag nuevo.
- `scripts/release_manifest.py` valida estructura, localizaciones y
  correspondencia con `pubspec.yaml`. Un manifiesto ausente, vacío, incompleto
  o de otra versión detiene el workflow antes de compilar.
- `forceUpdate: true` añade una línea exacta `[FORCE]` al cuerpo de GitHub para
  conservar el contrato OTA. Debe utilizarse solo cuando continuar con una
  versión anterior resulte inseguro o incompatible.
- La notificación de Discord depende de un role ID escrito en el workflow y de la disponibilidad del webhook.
- Las acciones externas usan tags mayores (`@v2`, `@v4`), no SHA inmutables. Es práctico, pero menos estricto frente a cambios de terceros.
- No hay trigger de `pull_request`; la calidad de una PR depende de ejecución local o manual.
- En una copia de desarrollo que conserve `floating-apps-examples/` o `run-actions-github/`, `flutter analyze` desde la raíz también inspecciona esos proyectos ignorados y puede fallar por sus dependencias independientes. Esos directorios no forman parte del checkout canónico; para una revisión local de la app puede usarse `flutter analyze lib`.

## Checklist de release

1. Actualizar `version:` en `pubspec.yaml` y crear
   `release-manifests/v<version>.json` con el mismo build y los tres idiomas.
2. Ejecutar `python3 scripts/release_manifest.py <manifest> --pubspec pubspec.yaml`.
3. Ejecutar `flutter pub get`, `flutter analyze --no-fatal-infos` y `flutter test`.
4. Probar instalación/descarga/overlay en un Android real.
5. Confirmar secretos y ejecutar primero el workflow de testing.
6. Ejecutar el workflow de release y comprobar APK, hashes, enlace estable
   `releases/latest/download/Sm64CDPY-arm64.apk`, evento hacia la web, PR
   generado y OTA por ABI.

## Desarrollo de temas desde Termux (2026-10-13)

La rama `custom-themes` se desarrolla sin Flutter/Dart local. Ambos workflows
hacen `flutter pub get` → `flutter gen-l10n` → Dart format → análisis antes del
build; testing también ejecuta ahora `flutter test`. El formato del runner no
crea commits. El artifact `flutter-source-sync` permite revisar e incorporar el
parche de generación/formato en el mismo commit desde Termux.

Para probar, seleccionar `custom-themes` en el workflow manual de testing o
subir un commit con `[testing]`. Continúan siendo necesarios los secretos de
firma existentes. No usar el workflow de publicación para obtener una prueba.
No se ejecutaron Actions ni builds como parte de la implementación local.
Ver [flujo y validación de temas](../cuatom_themea.md).

## Preparación 1.8.3+22

`pubspec.yaml` y `release-manifests/v1.8.3.json` están alineados. Testing valida
esa pareja, ejecuta los tests Python y adjunta preview EN/ES junto al JSON
localizado. Los tests de manifiesto derivan la versión desde pubspec.

Una ejecución manual de testing con `all_abis: true` permite revisar los tres
APKs firmados sin crear tags, releases, avisos Discord o dispatch al sitio.
El valor por defecto/push permanece en arm64. La publicación oficial sigue
requiriendo autorización y merge previo a main; las prereleases conservan su
flujo manual autorizado. Ver [preparación 1.8.3](RELEASE_1.8.3.md).

## Activación de mods — candidata 1.8.3

Biblioteca incluye una sección de unidades Lua del juego con switches de selección
para el próximo inicio. SAF autoriza `user`; el servicio nativo conserva ajustes,
comprueba identidades/incompatibilidades/tamaño, crea respaldo y verifica la escritura.
DynOS/Touch mantienen su contrato separado. La validación física está pendiente.
Plan, archivos, estados y matriz: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md).
Ambos workflows ejecutan también `:app:testReleaseUnitTest`. No hay merge ni release.
