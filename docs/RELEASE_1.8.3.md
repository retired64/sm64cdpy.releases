# Preparación oficial de SM64CDPY 1.8.3

Preparación iniciada el 2026-10-13 en `custom-themes`. Este documento no anuncia
una publicación: `main` no se ha fusionado, no se ha creado `v1.8.3` y no se ha
iniciado el workflow de release.

## Versión y APK

| Dato | Anterior | Preparado |
|---|---|---|
| Versión Flutter / Android versionName | 1.8.2 | 1.8.3 |
| Build base en pubspec/manifiesto | 21 | 22 |
| VersionCode APK arm32 | 211 | 221 |
| VersionCode APK arm64 | 212 | 222 |
| VersionCode APK x86_64 | 213 | 223 |
| Tag de lanzamiento | v1.8.2 | v1.8.3, todavía sin crear |
| Actualización forzada | false | false |

`pubspec.yaml` declara `1.8.3+22`. Gradle toma `flutter.versionName` y
`flutter.versionCode` y aplica su fórmula existente `build * 10 + código ABI`.
No hay que duplicar una versión literal en Gradle o Kotlin. Application ID,
firma, minSdk 24, Flutter 3.41.7, Dart 3.11.x y Java 17 conservan sus contratos.

Los tres assets finales conservan nombres estables:

- `Sm64CDPY-arm64.apk`
- `Sm64CDPY-arm32.apk`
- `Sm64CDPY-x86_64.apk`

No se cambian URLs públicas de descarga ni notas de versiones publicadas. La
actualización OTA continuará seleccionando la arquitectura apropiada y la
nueva versión no incluye el marcador `[FORCE]`.

## Changelog canónico localizado

[release-manifests/v1.8.3.json](../release-manifests/v1.8.3.json) es la única
fuente de notas EN, ES y PT-BR para este lanzamiento. El archivo tiene título,
resumen, destacados y cuatro secciones equivalentes en cada idioma:

| Sección | Cambio de producto |
|---|---|
| Temas de interfaz | Retro Manga predeterminado y Mario 64 incluido, con variantes claras/oscuras y selección persistente |
| Ajustes coherentes | Tema, modo e idioma despliegan opciones con el mismo diseño; idioma conserva sus animaciones; Mario suaviza solo Ajustes |
| Recuperación y contraste | Guardado de apariencia confirmado, doble toque bloqueado, fallback de diseños no disponibles y texto sobre rellenos con foreground adecuado |
| Panel flotante y actualizaciones | Burbuja oscura fija independiente; funcionamiento de descargas/instalaciones conservado; actualización opcional |

No se anuncian Odyssey/GameCube como opciones de esta versión, ni cambios de
WorkManager/SAF que no pertenecen al diff. Los IDs retirados de builds de prueba
se recuperan mediante el fallback ya implementado.

El renderer produce notas de GitHub en inglés y de Discord en español. El sitio
consume también PT-BR del mismo manifiesto. Las notas de prueba se pueden
revisar sin crear un tag o release.

### Fecha provisional

El esquema vigente exige un `publishedAt` válido. Su valor actual corresponde a
la preparación del manifiesto, **no a una release ya publicada**. Antes de
publicar, actualizarlo a la fecha/hora elegida de lanzamiento, con zona horaria,
y volver a validar/commitear. No agregar campos `draft` o `status` al JSON: su
esquema rechaza propiedades extra. El estado de preparación vive en este
documento y checklist.

## Validación de contenido y metadatos

Comandos ejecutables en Termux sin Flutter:

```sh
python3 scripts/release_manifest.py release-manifests/v1.8.3.json --pubspec pubspec.yaml
python3 -m unittest discover -s test/scripts -p '*_test.py' -v
git diff --check
```

La prueba del manifiesto actual ahora deriva el nombre de archivo desde
pubspec. Antes estaba fijada a `v1.8.2.json`, lo que habría bloqueado toda
publicación posterior. Los manifiestos históricos siguen validándose y no se
modifican.

En testing, antes de compilar, el workflow verifica manifiesto/pubspec y ejecuta
los tests Python. Conserva las vistas previas de notas EN/ES como artifact
`release-notes-preview-1.8.3`. Después genera ARB, formatea, analiza, ejecuta tests
Flutter y compila arm64. Ni la validación de notas ni ese artifact publican nada.

## Evidencia y pendientes

- La [build #177](https://github.com/retired64/sm64cdpy.releases/actions/runs/38502549130)
  terminó correctamente para `e02877f`: integración de idioma y Ajustes Mario,
  todavía con versión `1.8.2+21`.
- La preparación `1.8.3+22` necesita su propia build de testing; la evidencia del
  commit anterior no sustituye verificar el bump y los workflows nuevos.
- Los tests Python de manifiestos, concordancia con pubspec y render localizado
  se verifican localmente. Flutter/Dart no están instalados en este Termux.
- Sigue pendiente comprobar en teléfono el selector de idioma, los tres menús,
  texto grande, claro/oscuro/sistema y operaciones en curso.
- Testing produce arm64 por defecto. Su opción manual `all_abis: true` compila
  arm64/arm32/x86_64 sin publicar y permite validar las tres arquitecturas
  antes de considerar aprobada la distribución oficial.

## Flujo hasta main y publicación

1. Mantener la preparación y revisiones en `custom-themes`; no mezclar cambios
   ajenos ni modificar manifiestos de releases anteriores.
2. Subir un commit `[testing]` con el bump y revisar su análisis/tests/APK, notas
   preview y parche de generación/formato.
3. Ejecutar testing manual en `custom-themes` con `all_abis: true` y revisar
   el artifact: arm64 conserva `cdpy-<sha>.apk`; arm32/x86_64 llevan el sufijo
   correspondiente. Revisar las notas localizadas y completar la matriz física. Confirmar que
   solo se ofrecen Retro Manga y Mario 64 y que la burbuja conserva su tema.
4. Actualizar el `publishedAt` provisional y volver a ejecutar las compuertas.
5. Fusionar hacia `main` únicamente cuando el usuario lo autorice. Si aparecen
   conflictos, reconciliar contra el main vigente sin reset destructivo.
6. Autorizar explícitamente la publicación antes de ejecutar `buildAndroid.yaml`.
   Ese workflow crea tag, release, APKs y notificaciones: no es un build de prueba.
7. Para release oficial, seleccionar `main` y `prerelease: false`. Verificar los
   secretos de firma y `WEBSITE_DISPATCH_TOKEN` con sus permisos existentes.
8. El workflow valida versión/notas/tag, analiza y prueba, compila los tres APK,
   calcula checksums y publica `v1.8.3` sobre el SHA exacto construido. Después
   verifica assets, notifica Discord y solicita actualización del sitio.
9. Confirmar release, assets y enlaces de descarga, sincronización del sitio y
   actualización OTA desde una instalación 1.8.2 de cada arquitectura aplicable.

La publicación estable está bloqueada fuera de `main` por un nuevo guard en el
workflow. Las prereleases conservan su lanzamiento manual desde otras ramas,
pero también requieren autorización y no se ejecutan durante esta preparación.
`target_commitish: github.sha` fija la futura etiqueta al commit compilado; la
acción antes usaba por defecto la rama principal. Se mantiene la versión de la
acción y la toolchain existentes. [Contrato de la acción](https://github.com/softprops/action-gh-release/tree/v2).

## Checklist de salida

- [x] Versión `1.8.3+22` y manifiesto con el mismo build.
- [x] Notas EN/ES/PT-BR completas y `forceUpdate: false`.
- [x] Tres README y documentación técnica alineados.
- [x] Test de manifiesto actual independiente de una versión histórica.
- [x] Testing valida metadatos y entrega preview de notas.
- [x] Release estable requiere main y etiqueta sobre SHA construido.
- [ ] Nueva Actions de `1.8.3+22` aprobada.
- [ ] Incorporar/revisar parche generado si corresponde.
- [ ] Matriz física y compatibilidad de las tres arquitecturas.
- [ ] Fecha de publicación definitiva revisada.
- [ ] Autorización de merge y fusión a main.
- [ ] Autorización de publicación y workflow oficial.
- [ ] Verificación posterior de release/assets/OTA/sitio.

## Verificación de sincronización de estado

**Escritores:** versión/build en pubspec y notas localizadas en el nuevo
manifiesto. No se modifican preferencias de usuario ni eventos de instalación.

**Lectores y autoridad:** Flutter/Gradle leen pubspec para el paquete; los
workflows y el validador contrastan el manifiesto con esa versión/build. En la
app instalada, PackageInfo/Android siguen siendo la autoridad sobre la versión
real. GitHub Releases y el sitio usan las notas del manifiesto tras publicar.

**Concordancia:** `1.8.3+22` está alineada en la preparación. Los versionCodes
por ABI son una transformación documentada, no un build base distinto. Nueva
compilación y distribución siguen pendientes; main permanece sin modificar.

**Caches/Futures:** no se introducen caches, timers, readers de preferencias o
Futures Dart. Las caches de versión existentes se inicializan desde el paquete
instalado; no se sincronizan engines por variables estáticas.

**Hermanos revisados:** testing y publicación, los tres README, manifiesto/schema,
renderer/tests, Gradle/ABIs, UpdateService/UpdateConfig y documentación de temas,
arquitectura, estado y checklist. Overlay mantiene su diseño independiente.
