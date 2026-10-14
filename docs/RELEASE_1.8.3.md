# SM64CDPY 1.8.3 — preparación de merge y publicación

Revisión consolidada: 2026-10-14. Rama: `custom-themes`. Este documento describe
la candidata; no anuncia una publicación ni autoriza fusionar a `main`, crear
etiquetas, publicar APKs o ejecutar el workflow oficial.

## Versión y distribución

| Campo | Valor preparado |
|---|---|
| Pubspec / versionName | `1.8.3+22` / `1.8.3` |
| Build base | `22` |
| VersionCode arm32 / arm64 / x86_64 | `221` / `222` / `223` |
| Tag previsto | `v1.8.3`, sin crear durante esta preparación |
| Actualización obligatoria | No: `forceUpdate: false` |
| Toolchain | Flutter 3.41.7, Dart 3.11.x, Java 17 |
| Android mínimo | API 24 |
| APKs oficiales | `Sm64CDPY-arm32.apk`, `Sm64CDPY-arm64.apk`, `Sm64CDPY-x86_64.apk` |

`pubspec.yaml` es la autoridad de versión/build. Gradle utiliza esos valores y
su fórmula existente `build * 10 + ABI`. El manifiesto se valida contra pubspec.
Se conservan identidad del paquete, firma y nombres públicos de assets OTA.

## Alcance final del lanzamiento

1. **Biblioteca y mods del juego:** vista principal con switches para unidades
   Lua locales compatibles, propias o externas. Usa la identidad real que lee
   el juego; no inventa recibos a partir de títulos.
2. **Una sola vista de esos mods:** Detectados se retiró. Autor, categoría,
   descripción y versión informativa aparecen en Mods del juego, junto con
   búsqueda, filtros de activación, contadores y detalles de solo lectura.
   Instalados, Actualizaciones e Historial conservan sus funciones propias.
3. **Configuración verificable:** selección SAF de `user`, lectura/escritura de
   `sm64config.txt`, incompatibilidades locales conocidas, tamaño, respaldo privado,
   conservación de otras líneas y confirmación por relectura. Restaurar requiere
   confirmación. El usuario debe cerrar el juego: se configura el próximo inicio.
4. **Temas incluidos:** Retro Manga predeterminado, Mario 64 y SM64 Intro; todos admiten modo
   claro, oscuro o sistema, independiente de diseño e idioma. Mario utiliza
   superficies con relieve, fondos de cielo y selección con estrellas.
5. **Tipografía:** TypefaceMario64 exclusivamente en títulos de Mario, incluidos
   los nombres de Top downloads en Home. Cuerpo/descripciones usan la fuente
   predeterminada; Roboto cubre los acentos ausentes. Solo se empaqueta la OTF.
6. **Ajustes:** tema, modo e idioma comparten menús expandibles y animación. Los
   cambios se confirman después de guardar; fallos conservan el estado anterior.
7. **Contraste y recuperación:** roles de texto sobre rellenos y fallback a
   Retro Manga para IDs ausentes/retirados, conservando modo de apariencia.

La burbuja conserva su diseño oscuro independiente y su flujo de instalación.
DynOS/Touch Controls usan su contrato de packs, separado de los switches Lua.
No se anuncian Odyssey, GameCube, edición de packs o desinstalación nueva.

Detalles técnicos: [GAME_MOD_ACTIVATION.md](GAME_MOD_ACTIVATION.md),
[guía de temas](../cuatom_themea.md) y [arquitectura](ARCHITECTURE.md).

## Notas listas para revisión

Fuente canónica: [release-manifests/v1.8.3.json](../release-manifests/v1.8.3.json).
Título, resumen, destacados y cinco secciones equivalentes EN/ES/PT-BR cubren
el comportamiento final, sin el historial de implementaciones descartadas.

Previews generadas desde ese JSON, sin editar manualmente:

- [English](RELEASE_NOTES_1.8.3_EN.md) — GitHub.
- [Español](RELEASE_NOTES_1.8.3_ES.md) — revisión/Discord.
- [Português do Brasil](RELEASE_NOTES_1.8.3_PT_BR.md) — revisión/sitio.

El renderer existente alimenta GitHub/Discord y el manifiesto publicado permite
al sitio consumir los tres idiomas. Flutter mantiene OTA; no muestra estas
notas como una nueva pantalla. Cambiar notas exige modificar el JSON y regenerar
las previews. Releases anteriores permanecen intactas.

`publishedAt` sigue siendo provisional: el esquema exige una fecha ISO válida,
pero el valor de preparación no afirma que se publicó. Revisar fecha/hora real
antes de publicar y volver a validar; no agregar campos ajenos al esquema.

## Evidencia y comprobaciones

| Evidencia | Resultado observado al preparar esta revisión |
|---|---|
| [Testing #183](https://github.com/retired64/sm64cdpy.releases/actions/runs/38519260819) | Correcta: UI de Biblioteca y tests de ciclo de vida |
| [Testing #184](https://github.com/retired64/sm64cdpy.releases/actions/runs/38522079175) | Correcta: fusión de metadatos y parser Kotlin |
| [Testing #185](https://github.com/retired64/sm64cdpy.releases/actions/runs/38597376849) | Correcta: registro de fuentes |
| [Testing #186](https://github.com/retired64/sm64cdpy.releases/actions/runs/38601655928) | Correcta: solo fuente de títulos, descripción predeterminada |
| [Testing #187](https://github.com/retired64/sm64cdpy.releases/actions/runs/38605660934) | Correcta: Top downloads, análisis, 78 tests Flutter, tests Kotlin y APK arm64 |
| Validador de notas y cuatro tests Python | Correctos localmente |
| Compatibilidad del merge con `origin/main` `8bdc996` | `git merge-tree --write-tree` sin conflictos; sin merge real |

Se incorporó el artifact `flutter-source-sync` de #187, generado para `fc25c0f`:
traducciones producidas por `flutter gen-l10n` y formato Dart de los archivos
cambiados por esta rama. Se excluyeron nueve archivos cuyo único cambio sería
formato ajeno al alcance. No se editaron traducciones Dart generadas a mano.

La candidata consolidada debe superar su propia ejecución CI. Testing permite
`all_abis: true` manual o un commit `[testing] [all-abis]`: compila las tres
arquitecturas, ejecuta pruebas y sube artifacts, sin publicar. La condición ABI
es compartida por compilación y renombrado; el build común sigue siendo arm64.

## Pendientes antes de aprobar merge/release

- [x] Versión `1.8.3+22`, build y ABI codes alineados.
- [x] Changelog final equivalente en tres idiomas y actualización opcional.
- [x] Previews de notas regeneradas y documentación vigente consolidada.
- [x] Fuentes finales y traducciones/formato del runner incorporados.
- [x] Verificación de conflictos contra el main remoto consultado.
- [ ] CI del commit consolidado correcta para arm32/arm64/x86_64.
- [ ] Revisar artifacts de APK, notas y patch final de generación/formato.
- [ ] Confirmar última matriz física y revisión de títulos de Top downloads.
- [ ] Actualizar fecha de publicación definitiva.
- [ ] Autorización del usuario para merge a main.
- [ ] Autorización distinta para publicar `v1.8.3`.

El usuario confirmó anteriormente activación/desactivación en dispositivo y
el diseño de los temas. Eso no sustituye verificar el APK final. Matriz mínima:

- Retro/Mario en claro, oscuro y sistema; idioma, acentos y texto ampliado.
- Home, Top downloads, Ajustes, Biblioteca, detalles y diálogos.
- Mods existentes sin recibo y propios con recibo; información ausente/larga.
- Activar/desactivar con juego cerrado y comprobar selección en el siguiente inicio.
- Selección/cancelación de carpeta, acceso perdido, fallo al guardar y restauración.
- Instalar desde app/overlay, volver del segundo plano y reiniciar la app.
- Actualización desde 1.8.2 conservando carpeta, idioma, modo, favoritos e historial.
- Instalar los APKs de arquitecturas aplicables a los dispositivos disponibles.

## Secuencia de merge y publicación

1. Revisar la candidata y los checks/artifacts. Los cambios del usuario en
   `.gitignore` y el clon `sm64coopdx/` no forman parte de esta preparación.
2. Antes del merge autorizado, actualizar referencias remotas y comprobar otra
   vez conflictos/versión si main recibió cambios. No resetear trabajo local.
3. Fusionar `custom-themes` a `main` solo cuando lo indique el usuario. El diff
   incluye comportamiento, metadatos, recursos, pruebas y documentación juntos.
4. Revisar `publishedAt`, versión/build y el SHA final. Si el merge modifica
   código o resuelve conflictos, volver a validar ese resultado.
5. Publicar únicamente con autorización explícita. Ejecutar `buildAndroid.yaml`
   sobre `main`, con `prerelease: false`, después de revisar firma y secretos.
6. El workflow oficial valida manifiesto/tag y acceso al sitio, prueba, compila
   tres APKs, ejecuta tests nativos y publica `v1.8.3` sobre `github.sha`. No usarlo
   para obtener pruebas: crea release/assets y realiza avisos/dispatch externos.
7. Verificar tag, tres APKs, checksums, manifiesto localizado, enlaces, sitio y
   OTA de cada ABI disponible. No declarar publicación completa con assets faltantes.

La release estable está bloqueada fuera de `main`. El objetivo del tag es el
SHA compilado; no se etiqueta automáticamente otra rama por defecto.

## Texto propuesto para el PR de merge

**Title:** Prepare SM64CDPY 1.8.3: game mod controls and Mario 64 theme

**Description:**

Version 1.8.3 adds verified activation of compatible local Lua mods for the next
game start. Library replaces the separate Detected view with Game mods, combining
activation, local search and mod metadata while keeping installation receipts,
updates and history separate. Configuration edits preserve other settings and
provide verified saves and a private recovery backup.

The app includes Retro Manga, Mario 64 and SM64 Intro with independent appearance modes,
matching animated Settings selectors and Mario-only heading typography. Mario
rebuilds its scenes, opaque materials, square frames, controls and typography
from a private user-selected vanilla US ROM. The initial selection waits for
confirmed import; cancellation preserves the previous theme. Subsequent
selections reuse the prepared local set. The APK bundles no extracted game artwork. Version
metadata and localized release notes are aligned to 1.8.3+22. The overlay keeps
its independent design. Attach the consolidated CI run and device checks before
approval; this PR does not authorize publishing a release.

## Comandos de validación local

```sh
python3 scripts/release_manifest.py release-manifests/v1.8.3.json --pubspec pubspec.yaml
python3 -m unittest discover -s test/scripts -p '*_test.py' -v
git diff --check
```

Flutter/Dart no están instalados en Termux. Gen-l10n, formato, análisis, tests,
compilación y tests Kotlin se ejecutan en Actions. La simulación de merge no
prueba funcionalidad Android ni reemplaza el resultado de CI.

## Verificación de sincronización de estado

- **Escritores/lectores:** pubspec define versión/build; manifiesto define notas;
  workflows/validador/Gradle consumen esos valores. ARB genera traducciones Dart;
  previews derivan del manifiesto y no compiten como fuente de verdad.
- **Autoridad:** paquete instalado para versión real; configuración del juego
  para selección persistida; WorkManager para instalaciones activas. Esta
  preparación no modifica esos protocolos. La referencia nativa de recursos ROM
  y sus archivos privados confirmados son autoridad de la importación visual.
- **Concordancia:** metadatos y contenido final alineados; checks consolidados y
  publicación permanecen pendientes hasta confirmarse. Main no se modificó.
- **Caches/Futures:** recursos PNG inmutables por generación UUID e ImageCache;
  cambio de generación cambia claves y el siguiente arranque limpia archivos
  inactivos. El arranque inicia la lectura de recursos mediante un
  unawaited intencional con errores capturados; UI espera perform/cancel. Los
  datos de release, traducciones y flag CI conservan sus fuentes únicas.
- **Hermanos:** tres idiomas, tres ABIs, testing/release, README/documentación,
  app/overlay, fuente de títulos/cuerpo, parser/editor de mods, biblioteca,
  portadas/detalle y selección/importación ROM revisados.


## Mario 64: recursos locales y menú original

Se integra la importación opcional de 15 texturas desde una ROM vanilla US del
usuario, sin modificar el juego ni incluir imágenes extraídas en el APK. Marcos,
selección, fondo de Biblioteca/Ajustes y contadores siguen el tema Mario; Retro y
overlay conservan su diseño. Plan, contrato, persistencia, cancelación y matriz
de pruebas en [MARIO_ROM_THEME.md](MARIO_ROM_THEME.md). Validado en [Testing #192](https://github.com/retired64/sm64cdpy.releases/actions/runs/38613827573): análisis, 83 tests Flutter,
APK arm64 y tests Kotlin correctos para `f23034a`. Sigue pendiente la matriz
física con ROM real; estos tests usan datos sintéticos y no una ROM del usuario.


## Reconstrucción Mario 64 v2 — nueva validación pendiente

Se sustituye la interpretación de 15 texturas débiles por 151 imágenes y tres
fuentes privadas derivadas de ROM: materiales opacos, cielos Clouds/BBH, cursor,
HUD, tipografías y marcos cuadrados. Se conectan todas las pantallas y widgets
principales. La selección de Mario coordina importación antes de guardar tema;
v1 conserva sus recursos mientras se pide reimportación. Contrato actual en
[MARIO_ROM_THEME.md](MARIO_ROM_THEME.md). La evidencia #192 valida v1, no este cambio v2.
