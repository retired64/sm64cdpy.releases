# Catálogos de distribución

Esta carpeta contiene los JSON de catálogo distribuidos por el proyecto.
`assets/db/` conserva las copias de respaldo empaquetadas en el APK, declaradas
en `pubspec.yaml`. Tener ambas ubicaciones es intencional; no eliminar una como
si fuera una duplicación accidental.

Al cambiar contenido, revisar el catálogo de distribución y su respaldo
correspondiente. No imponer igualdad automática entre archivos sin revisar el
contrato y sus diferencias intencionales. Render96 tiene respaldo empaquetado,
pero no un archivo hermano en esta carpeta.

Ver [contrato del catálogo](../docs/CATALOG_DATABASE_CONTRACT.md) y
[traducciones precalculadas](../docs/PRECOMPUTED_MOD_TRANSLATIONS.md).
Los analizadores están en `scripts/`; los CSV y resultados intermedios se
mantienen fuera de los recursos de producción.
