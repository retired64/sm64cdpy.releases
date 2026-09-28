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
- Firma el APK con secretos, ejecuta `flutter analyze` y conserva el log.
- Compila solo arm64 y publica un artifact durante 7 días.
- No crea tag ni GitHub Release.

### `buildAndroid.yaml`

- Solo se ejecuta manualmente y permite marcar una prerelease.
- Lee `versionName`/`versionCode` de `pubspec.yaml`.
- Verifica que no exista el tag `v<versionName>`.
- Ejecuta análisis, compila arm64/arm32/x86_64 y guarda un artifact temporal.
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

- Los workflows están alineados con Java 17, Flutter 3.41.7 y los nombres de APK que consume la selección OTA.
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
6. Ejecutar el workflow de release y comprobar APK, hashes, evento hacia la
   web, PR generado y OTA por ABI.
