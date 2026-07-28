"""
providers/flutter.py

Provider específico para docs.flutter.dev.
"""

from .base import fetch_and_convert

SELECTORS = [
    "main article",
    "article",
    "main .content",
    "main",
    "body",
]


def fetch(url: str) -> str:
    return fetch_and_convert(url, SELECTORS)
