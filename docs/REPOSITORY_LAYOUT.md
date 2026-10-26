# Organización y mantenimiento del repositorio

Revisión: 2026-10-26. La limpieza conserva el producto Android y separa código,
datos de distribución, documentación, material gráfico y herramientas.

## Mapa de carpetas

| Ruta | Contenido y criterio |
|---|---|
| `lib/` | Código Flutter por responsabilidades; ver límites de capas más abajo |
| `android/` | Integración Android, SAF, Workers y recursos nativos |
| `assets/`, `fonts/` | Recursos de ejecución y fuentes declarados por Flutter |
| `db/` | Catálogos de distribución; `assets/db/` es el respaldo del APK |
| `test/` | Pruebas y fixtures del producto |
| `docs/` | Contratos, arquitectura y guías técnicas vigentes |
| `docs/releases/` | Registros de preparación y notas de versiones |
| `docs/archive/` | Auditorías y planes históricos, con contexto de su fecha |
| `docs/schemas/` | Esquemas de datos versionados |
| `release-manifests/` | Fuente canónica de notas localizadas de publicación |
| `scripts/` | Automatización de CI, catálogos y validación |
| `tools/` | Herramientas gráficas opcionales y utilidades legacy identificadas |
| `media/branding/` | Originales gráficos de marca fuera del APK |
| `media/screenshots/` | Capturas promocionales fuera del APK |
| `.github/` | Workflows y configuración de GitHub |

Los Markdown de la raíz son `README.md` (inglés) y `AGENTS.md` (reglas de
desarrollo para todo el repositorio). Las traducciones ES/PT-BR, el changelog
y la guía de compilación viven en `docs/`; el plan anterior APOYO está en `docs/archive/PLAYER_IMPLEMENTATION_PLAN.md`.
La licencia y la configuración del proyecto permanecen en la raíz. No colocar APK, ZIP, exportaciones
de catálogos ni copias de documentación de terceros en la raíz.

## Clean Architecture: límites y alcance real

Se conserva la separación existente; esta tarea no convierte el proyecto en
una implementación nueva de Clean Architecture ni mueve código de ejecución.

- **Dominio (`lib/domain`)**: entidades y contratos. Evitar importar UI,
  canales Android o detalles de persistencia al añadir contratos nuevos.
- **Datos (`lib/data`)**: modelos, fuentes y repositorios que materializan los
  contratos. Las tarjetas no deben leer JSON ni persistir resultados.
- **Servicios (`lib/services`)**: coordinación de plataforma, instalación,
  descargas, ROM, permisos y OTA. La autoridad de trabajos sigue en WorkManager.
- **Presentación (`lib/presentation`)**: providers, pantallas y widgets.
  Solicita acciones y representa estados; no implementa extracción SAF.
- **Núcleo (`lib/core`)**: constantes, navegación, tema y utilidades comunes;
  no usarlo como depósito de lógica de negocio sin propietario claro.
- **Overlay (`lib/overlay`)**: presentación y bridge de un engine separado.
  Intercambiar mensajes y reconciliar estado; nunca sincronizar por estáticos.
- **Android**: canales, Workers y acceso a documentos. La extracción compartida
  permanece en `SafZipExtractor`; no duplicarla en pantallas o herramientas.

`lib/widgets/update_dialog.dart` es una ubicación heredada existente; no se mueve
a ciegas durante la limpieza documental. Las futuras migraciones de código
requieren revisar imports, consumidores y pruebas de su flujo completo.
La [arquitectura técnica](ARCHITECTURE.md) mantiene los contratos detallados.

## Decisiones de limpieza

- Se salva íntegramente el contenido existente de [ROM_CONVERTER.md](ROM_CONVERTER.md)
  y se elimina la regla que lo ocultaba a Git.
- Se recupera la guía de temas borrada como [CUSTOM_THEMES.md](CUSTOM_THEMES.md),
  conservando sus fechas históricas y corrigiendo enlaces.
- Se recuperan auditorías y planes propios en `docs/archive/`.
- Se conservan manifiestos y notas históricas; no se reescriben sus resultados.
- Se retiran el scaffold Linux, la configuración de editor con ruta personal,
  el recolector de documentación externa y su copia local de dependencias.
- Se mantiene la retirada previa de `html-web/`, `oracle/`, APK antiguo y JSON
  traducido intermedio. La web actual vive en su repositorio independiente.
- Se retiran previews PNG generados; se conservan generador, ejemplo y fuentes.
- Se saca el analizador y su CSV de `assets/db/`; allí quedan datos del producto.
- No se deduplican catálogos de distribución/respaldo ni se optimizan recursos
  empaquetados sin pruebas de su uso y de la compatibilidad visual.

El material retirado que aún existía antes de esta reorganización tiene una
copia local de recuperación en
`/data/data/com.termux/files/usr/tmp/sm64cdpy-cleanup-20261026/`.
Es temporal y no forma parte de Git. Los archivos que el usuario ya había
borrado siguen recuperables desde su commit anterior.

## Reglas para mantenerlo ligero

Documentación propia se versiona por defecto; `.gitignore` excluye clones,
referencias externas, temporales y entregables generados. Antes de agregar,
revisar `git status --short`, especialmente los archivos nuevos.
No subir APK/AAB ni ROMs. Generar salidas en `output/` y publicar entregables
solo mediante el flujo autorizado de releases. Las rutas de runtime, assets,
canales y workflows se conservan.

Borrar archivos reduce el checkout, pero no elimina blobs del historial Git.
Reescribir ese historial requiere una tarea aparte y coordinación de los clones.

## Validación de esta reorganización

Ejecutar `python scripts/check_doc_links.py` y `git diff --check`.
La comprobación de enlaces solo valida destinos locales, no páginas externas
ni fragmentos internos. Flutter/Kotlin y pruebas físicas corresponden a cambios
de ejecución; aquí no se modifican Dart, Kotlin, ARB, canales ni Workers.

Resultado del 2026-10-26: enlaces locales correctos en 77 documentos, 16
pruebas Python existentes correctas, manifiesto 1.9.1+29 válido y
`git diff --check` limpio. Contenido de archivos en HEAD: 107,29 MiB; propuesta:
24,93 MiB (82,36 MiB menos, incluyendo las eliminaciones previas del usuario).
No incluye `.git`, archivos ignorados ni el respaldo temporal.

Flutter y Dart no están disponibles en PATH y esta copia no contiene
`android/gradlew`; no se ejecutaron análisis Flutter, compilación Kotlin ni
pruebas físicas. No hubo cambios de código de ejecución que verificar aquí.
No se creó commit, tag ni release.
