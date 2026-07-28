"""
providers/base.py

Utilidades compartidas por todos los providers:
- Descargar HTML de una URL
- Extraer solo el contenido principal (sin nav, footer, ads, etc.)
- Convertir ese contenido a Markdown limpio

Cada provider (android.py, flutter.py) solo define QUÉ selectores CSS
usar para encontrar el contenido principal de ese sitio en particular.
"""

from __future__ import annotations

import requests
from bs4 import BeautifulSoup
import html2text

DEFAULT_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (compatible; aidocs-cli/1.0; "
        "+local-context-tool-for-ai-assistants)"
    )
}

# Tags que casi nunca aportan valor como contexto para una IA
NOISE_TAGS = [
    "script",
    "style",
    "nav",
    "footer",
    "header",
    "noscript",
    "iframe",
    "svg",
    "form",
]

# Selectores de elementos "decorativos" típicos de devsite/docs
# (banners de feedback, breadcrumbs, botones de compartir, etc.)
NOISE_SELECTORS = [
    ".devsite-page-rating",
    ".devsite-feedback",
    ".devsite-banner",
    ".devsite-breadcrumb",
    ".devsite-toc",
    ".devsite-nav",
    "[class*='cookie']",
    "[class*='breadcrumb']",
    "[class*='sidebar']",
    "[class*='toc']",
]


class FetchError(Exception):
    """Error al descargar o procesar una URL."""


def fetch_html(url: str, timeout: int = 20) -> str:
    try:
        resp = requests.get(url, headers=DEFAULT_HEADERS, timeout=timeout)
        resp.raise_for_status()
        return resp.text
    except requests.RequestException as exc:
        raise FetchError(f"No se pudo descargar {url}: {exc}") from exc


def extract_main_content(html: str, selectors: list[str] | None = None):
    """
    Intenta ubicar el contenedor principal del contenido probando una
    lista de selectores CSS en orden. Si ninguno funciona, cae de vuelta
    a <body>.
    """
    soup = BeautifulSoup(html, "lxml")

    for tag_name in NOISE_TAGS:
        for tag in soup.find_all(tag_name):
            tag.decompose()

    for selector in NOISE_SELECTORS:
        for tag in soup.select(selector):
            tag.decompose()

    selectors = selectors or ["main", "article", "#content", "body"]

    content = None
    for selector in selectors:
        content = soup.select_one(selector)
        if content is not None:
            break

    if content is None:
        content = soup.body or soup

    return content


def html_to_markdown(content_fragment) -> str:
    converter = html2text.HTML2Text()
    converter.ignore_links = False
    converter.ignore_images = True
    converter.ignore_emphasis = False
    converter.body_width = 0  # no forzar saltos de línea artificiales
    converter.single_line_break = True

    markdown = converter.handle(str(content_fragment))

    # Colapsar líneas en blanco excesivas que deja html2text
    lines = markdown.splitlines()
    cleaned: list[str] = []
    blank_run = 0
    for line in lines:
        if line.strip() == "":
            blank_run += 1
            if blank_run > 2:
                continue
        else:
            blank_run = 0
        cleaned.append(line)

    return "\n".join(cleaned).strip() + "\n"


def fetch_and_convert(url: str, selectors: list[str] | None = None) -> str:
    html = fetch_html(url)
    content = extract_main_content(html, selectors)
    return html_to_markdown(content)
