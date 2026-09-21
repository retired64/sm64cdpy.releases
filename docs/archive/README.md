# Archivo de documentación y referencias

Este índice conserva material útil sin presentarlo como documentación vigente. No se eliminaron ni trasladaron los repositorios/copias pesadas para evitar un cambio de cientos de MB y no romper rutas históricas.

## Auditorías y planes históricos

| Ubicación | Clasificación | Motivo |
|---|---|---|
| `../../revision-app.md` | Auditoría histórica | Mezcla hallazgos ya corregidos con otros sin revalidar |
| `../../floating-check-list.md` | Plan histórico | Marca como pendientes partes del bridge que ya están implementadas |
| `../../.opencode/plans/` | Planes de 1.7.0 | Material de trabajo, no especificación actual |
| `../estructura-sm64cdpy.md` | Arquitectura sustituida | Contiene versiones, conteos y módulos anteriores |
| `../ideas-coopdx64.md` | Ideas/backlog antiguo | Algunas propuestas ya existen con otro diseño |
| [`FUTURE-TRANSLATION-IDEAS.md`](FUTURE-TRANSLATION-IDEAS.md) | Propuesta futura pública | Traducción incremental de descripciones; no forma parte de 1.7.0 |

## Referencia externa o copiada

| Ubicación | Contenido |
|---|---|
| `../../oracle/` | Copias de documentación de Android/Flutter; pueden quedar desactualizadas |
| `../foreground_services.md` | Copia de documentación Android, no guía específica del proyecto |
| `../lua_sm64coopdx.md` | Referencia del entorno Lua de SM64CoopDX |
| `../AndroidManifest-sm64coopdxandroid.xml` | Manifest de la aplicación del juego usado como referencia |
| `../komi-store/` | Copia local de un proyecto externo; no forma parte de SM64CDPY y no se publica |
| `../../floating-apps-examples/` | Repositorio local con ejemplos de la dependencia del overlay; no se publica |
| `../../run-actions-github/` | Copia de trabajo local para Actions; no es fuente canónica ni se publica |

## Herramientas, muestras y binarios

`docs/coopdx64.py`, `docs/generate_mods_metadata.py`, `docs/db/`, `docs/DevilCoins.lua`, `docs/Render96.HD.Texture.Pack.1.3.26.7.7.7z`, `docs/res/` e `info.txt` son insumos, muestras o herramientas históricas. No describen el comportamiento actual de la aplicación y no deben enlazarse desde el README principal como documentación activa.

Antes de reutilizar cualquier elemento archivado, contrástalo con `pubspec.yaml`, `lib/`, `android/` y `.github/workflows/`.

Estos directorios están cubiertos por las reglas de `.gitignore`. Su presencia en este índice solo explica por qué pueden existir en el workspace; no implica que su contenido deba agregarse al repositorio.
