# Herramientas gráficas y utilidades históricas

Ejecutar desde la raíz del repositorio, salvo indicación expresa. Estas
herramientas no forman parte del APK ni son pasos implícitos del build.

| Herramienta | Uso |
|---|---|
| `android-icons/generate_icons.py` | Generar iconos Android desde una imagen; consultar `--help` antes de escribir recursos |
| `theme-preview-screenshot/fusionar_diagonal.py` | Combinar dos capturas; entradas y salida explícitas |
| `preview-changelogs-PNG/generate_wallpaper.py` | Generador histórico de previews con JSON explícito; no consume automáticamente el manifiesto actual |
| `legacy/rename_apk.sh` | Renombrador histórico con nombres versionados; no usar como contrato de releases nuevas |

Las herramientas gráficas requieren Pillow (`python -m pip install Pillow`).
Los PNG generados del changelog se retiraron; generar salidas en `output/`
(ignorado). Se conservaron código, ejemplo JSON y fuentes del generador.

Los APK actuales se renombran en los workflows con nombres estables por ABI.
Ver [CI/CD](../docs/CI_CD.md). Los scripts usados por CI y mantenimiento de
datos están en [scripts](../scripts/README.md).
