# GitHub Actions y releases

Revisado el 2026-09-20.

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
- Renombra APK, calcula SHA-256, genera notas desde `lib/presentation/screens/changelog_screen.dart` y publica el release.
- Notifica releases estables por Discord.

## Secretos necesarios

- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `DISCORD_WEBHOOK_URL` (solo notificación estable)

`GITHUB_TOKEN` lo proporciona GitHub Actions con permiso `contents: write` en el workflow de release.

## Observaciones de auditoría

- Los workflows están alineados con Java 17, Flutter 3.41.7 y los nombres de APK que consume la selección OTA.
- No hay suite de tests; ambos dependen de análisis estático y éxito del build.
- El workflow de release dice que se debe subir `versionCode` si el tag existe, pero el tag solo usa `versionName`: para otro release hay que cambiar la parte anterior al `+` (y normalmente también incrementar el build number).
- El release extrae el changelog con `grep`/`awk`; un cambio de formato en el archivo Dart puede producir notas genéricas aunque la compilación funcione.
- La notificación de Discord depende de un role ID escrito en el workflow y de la disponibilidad del webhook.
- Las acciones externas usan tags mayores (`@v2`, `@v4`), no SHA inmutables. Es práctico, pero menos estricto frente a cambios de terceros.
- No hay trigger de `pull_request`; la calidad de una PR depende de ejecución local o manual.
- En una copia de desarrollo que conserve `floating-apps-examples/` o `run-actions-github/`, `flutter analyze` desde la raíz también inspecciona esos proyectos ignorados y puede fallar por sus dependencias independientes. Esos directorios no forman parte del checkout canónico; para una revisión local de la app puede usarse `flutter analyze lib`.

## Checklist de release

1. Actualizar `version:` en `pubspec.yaml` y crear la entrada equivalente en el changelog de la app.
2. Ejecutar `flutter pub get` y `flutter analyze --no-fatal-infos`.
3. Probar instalación/descarga/overlay en un Android real.
4. Confirmar secretos y ejecutar primero el workflow de testing.
5. Ejecutar el workflow de release y comprobar APK, hashes y OTA por ABI.
