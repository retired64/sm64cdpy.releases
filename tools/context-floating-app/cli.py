#!/usr/bin/env python3
"""
aidocs — CLI local de documentación enfocada al desarrollo del
panel flotante (overlay) de tu app.

No es un navegador de documentación genérico: es una base de
conocimiento local que le da contexto real y actualizado a tu
IA (opencode, claude, o cualquier otra) sobre las APIs oficiales
de Android y Flutter que necesitas para el overlay.

Comandos:
    fetch                  Descarga/actualiza todas las páginas de config.yaml
    fetch <categoria>      Descarga solo una categoría (android | flutter)
    list                   Muestra qué documentos hay descargados
    search <termino>       Busca un término en todos los documentos
    show <nombre>          Imprime un documento completo en Markdown
    context <grupo>        Concatena los documentos de un grupo (ver index.json)
    groups                 Lista los grupos de contexto disponibles

Ejemplos:
    python cli.py fetch
    python cli.py list
    python cli.py search overlay
    python cli.py show windowmanager
    python cli.py context overlay > overlay.md
    python cli.py context fase2_ventana_flotante --output fase2.md
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import yaml

from providers import PROVIDERS

ROOT = Path(__file__).resolve().parent
DOCS_DIR = ROOT / "docs"
CONFIG_PATH = ROOT / "config.yaml"
INDEX_PATH = ROOT / "index.json"


# ---------------------------------------------------------------------------
# Carga de configuración
# ---------------------------------------------------------------------------

def load_config() -> dict:
    if not CONFIG_PATH.exists():
        print(f"✗ No se encontró {CONFIG_PATH}", file=sys.stderr)
        sys.exit(1)
    with open(CONFIG_PATH, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh) or {}


def load_index() -> dict:
    if not INDEX_PATH.exists():
        return {}
    with open(INDEX_PATH, "r", encoding="utf-8") as fh:
        return json.load(fh)


def doc_path(category: str, name: str) -> Path:
    return DOCS_DIR / category / f"{name}.md"


# ---------------------------------------------------------------------------
# Comando: fetch
# ---------------------------------------------------------------------------

def cmd_fetch(args: argparse.Namespace) -> None:
    config = load_config()

    categories = [args.category] if args.category else list(config.keys())

    for category in categories:
        if category not in config:
            print(f"✗ Categoría desconocida: {category}", file=sys.stderr)
            continue

        if category not in PROVIDERS:
            print(
                f"✗ No hay provider registrado para '{category}' "
                f"(revisa providers/__init__.py)",
                file=sys.stderr,
            )
            continue

        fetch_fn = PROVIDERS[category]
        out_dir = DOCS_DIR / category
        out_dir.mkdir(parents=True, exist_ok=True)

        pages = config[category] or {}
        print(f"\n{category.capitalize()}")
        print("Downloading...\n")

        for name, url in pages.items():
            try:
                markdown = fetch_fn(url)
            except Exception as exc:  # noqa: BLE001
                print(f"✗ {name}  ({exc})")
                continue

            header = f"<!-- source: {url} -->\n\n"
            out_path = out_dir / f"{name}.md"
            out_path.write_text(header + markdown, encoding="utf-8")
            print(f"✓ {name}")

    print("\nDone.")


# ---------------------------------------------------------------------------
# Comando: list
# ---------------------------------------------------------------------------

def cmd_list(args: argparse.Namespace) -> None:
    if not DOCS_DIR.exists() or not any(DOCS_DIR.iterdir()):
        print("No hay documentos descargados todavía. Corre: python cli.py fetch")
        return

    for category_dir in sorted(DOCS_DIR.iterdir()):
        if not category_dir.is_dir():
            continue
        md_files = sorted(category_dir.glob("*.md"))
        if not md_files:
            continue
        print(f"\n{category_dir.name.capitalize()}\n")
        for md_file in md_files:
            print(f"  {md_file.stem}")
    print()


# ---------------------------------------------------------------------------
# Comando: search
# ---------------------------------------------------------------------------

def cmd_search(args: argparse.Namespace) -> None:
    term = args.term.lower()
    if not DOCS_DIR.exists():
        print("No hay documentos descargados todavía. Corre: python cli.py fetch")
        return

    found_any = False
    for md_file in sorted(DOCS_DIR.rglob("*.md")):
        text = md_file.read_text(encoding="utf-8", errors="ignore")
        matches = [
            line.strip()
            for line in text.splitlines()
            if term in line.lower() and line.strip()
        ]
        if matches:
            found_any = True
            rel = md_file.relative_to(DOCS_DIR)
            print(f"\n{rel}")
            for line in matches[: args.max_matches]:
                print(f"  {line}")

    if not found_any:
        print(f"Sin resultados para '{args.term}'.")


# ---------------------------------------------------------------------------
# Comando: show
# ---------------------------------------------------------------------------

def find_doc(name: str) -> Path | None:
    """Busca un documento por nombre en cualquier categoría."""
    if "/" in name:
        category, doc_name = name.split("/", 1)
        candidate = doc_path(category, doc_name)
        return candidate if candidate.exists() else None

    matches = list(DOCS_DIR.glob(f"*/{name}.md"))
    return matches[0] if matches else None


def cmd_show(args: argparse.Namespace) -> None:
    path = find_doc(args.name)
    if path is None:
        print(f"✗ No se encontró el documento '{args.name}'.", file=sys.stderr)
        print("  Usa 'python cli.py list' para ver los nombres disponibles.")
        sys.exit(1)
    print(path.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# Comando: context
# ---------------------------------------------------------------------------

def cmd_context(args: argparse.Namespace) -> None:
    index = load_index()

    if args.group not in index:
        print(f"✗ Grupo desconocido: '{args.group}'", file=sys.stderr)
        if index:
            print("  Grupos disponibles: " + ", ".join(index.keys()))
        sys.exit(1)

    doc_names = index[args.group]
    chunks: list[str] = []
    missing: list[str] = []

    for entry in doc_names:
        path = find_doc(entry)
        if path is None:
            missing.append(entry)
            continue
        title = entry.replace("/", " / ")
        chunks.append(f"# {title}\n\n{path.read_text(encoding='utf-8')}")

    if missing:
        print(
            "✗ Faltan documentos (corre 'python cli.py fetch' primero): "
            + ", ".join(missing),
            file=sys.stderr,
        )

    if not chunks:
        sys.exit(1)

    separator = "\n\n---\n\n"
    full_markdown = (
        f"<!-- Contexto generado por aidocs para el grupo: {args.group} -->\n\n"
        + separator.join(chunks)
    )

    if args.output:
        out_path = Path(args.output)
        out_path.write_text(full_markdown, encoding="utf-8")
        print(f"✓ Contexto guardado en {out_path}")
    else:
        print(full_markdown)


# ---------------------------------------------------------------------------
# Comando: groups
# ---------------------------------------------------------------------------

def cmd_groups(args: argparse.Namespace) -> None:
    index = load_index()
    if not index:
        print("No hay grupos definidos en index.json")
        return
    print("\nGrupos de contexto disponibles:\n")
    for group, docs in index.items():
        print(f"  {group}")
        for d in docs:
            print(f"      - {d}")
        print()


# ---------------------------------------------------------------------------
# Parser principal
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="aidocs",
        description=(
            "Base de conocimiento local de documentación oficial "
            "(Android + Flutter) para dar contexto a tu IA."
        ),
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_fetch = sub.add_parser("fetch", help="Descarga/actualiza documentación")
    p_fetch.add_argument(
        "category", nargs="?", default=None, help="Categoría a descargar (android | flutter)"
    )
    p_fetch.set_defaults(func=cmd_fetch)

    p_list = sub.add_parser("list", help="Lista los documentos descargados")
    p_list.set_defaults(func=cmd_list)

    p_search = sub.add_parser("search", help="Busca un término en todos los documentos")
    p_search.add_argument("term", help="Término a buscar")
    p_search.add_argument(
        "--max-matches", type=int, default=10, help="Máximo de líneas a mostrar por archivo"
    )
    p_search.set_defaults(func=cmd_search)

    p_show = sub.add_parser("show", help="Imprime un documento completo")
    p_show.add_argument("name", help="Nombre del documento (ej: windowmanager o android/windowmanager)")
    p_show.set_defaults(func=cmd_show)

    p_context = sub.add_parser(
        "context", help="Concatena los documentos de un grupo definido en index.json"
    )
    p_context.add_argument("group", help="Nombre del grupo (ver 'python cli.py groups')")
    p_context.add_argument(
        "--output", "-o", default=None, help="Guardar el resultado en un archivo en vez de stdout"
    )
    p_context.set_defaults(func=cmd_context)

    p_groups = sub.add_parser("groups", help="Lista los grupos de contexto disponibles")
    p_groups.set_defaults(func=cmd_groups)

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
