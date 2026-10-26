# Scripts de mantenimiento

Ejecutar desde la raíz del repositorio. Los workflows conservan sus rutas.

| Script | Responsabilidad |
|---|---|
| `release_manifest.py` | Validar manifiestos y generar notas localizadas |
| `prepare_android_ndk.py` | Preparar y verificar la versión de NDK exigida por Flutter |
| `precompute_catalog_translations.py` | Generar traducciones del catálogo fuera del APK |
| `validate_translated_catalog.py` | Verificar el resultado antes de distribuirlo |
| `analyze_catalog_categories.py` | Analizador interactivo histórico; busca JSON en el directorio de ejecución |
| `check_doc_links.py` | Comprobar destinos locales de enlaces Markdown de documentación |

Para analizar categorías: `cd db` y después
`python ../scripts/analyze_catalog_categories.py`. El CSV es una salida local
ignorada; nunca se incluye como asset de la aplicación.
Las dependencias opcionales de traducción están en
`catalog_translation_requirements.txt`. No instalar paquetes de scraping como
requisito del build Flutter.
