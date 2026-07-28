"""
Registro de providers disponibles.

Para añadir soporte a un nuevo sitio de documentación:
  1. Crea providers/<nombre>.py con una función fetch(url) -> str (markdown)
  2. Regístralo aquí en PROVIDERS
  3. Añade una sección con ese nombre en config.yaml
"""

from . import android, flutter

PROVIDERS = {
    "android": android.fetch,
    "flutter": flutter.fetch,
}
