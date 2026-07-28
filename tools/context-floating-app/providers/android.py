"""
providers/android.py

Provider específico para developer.android.com.
Define los selectores CSS donde suele vivir el contenido real
en las páginas de guías y de referencia de la API.
"""

from .base import fetch_and_convert

# devsite (developer.android.com) usa distintos contenedores según
# sea una página de "guide" o de "reference". Probamos varios en orden.
SELECTORS = [
    "article.devsite-article",
    "div.devsite-article-body",
    "main",
    "article",
    "body",
]


def fetch(url: str) -> str:
    return fetch_and_convert(url, SELECTORS)
