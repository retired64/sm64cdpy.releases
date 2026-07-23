#!/usr/bin/env python3
"""
generate_wallpaper.py
----------------------
Superpone info de versión/changelog sobre el fondo generado por IA,
usando la paleta y el lenguaje visual de RetroTheme (navy + crema + teal/amber).

Uso:
    python3 generate_wallpaper.py --bg fondo.png --data changelog.json --out wallpaper.png

El JSON de entrada replica el esquema de _VersionData/_ChangeGroupData de tu
ChangelogScreen.dart (ver changelog.example.json):
{
  "app_name": "SM64CoopDX",
  "version": "1.4.5",
  "tag": "Latest",
  "date": "July 2026",
  "groups": [
    {"type": "added",    "items": ["Nuevo carrusel en Home..."]},
    {"type": "improved", "items": ["Botones GO TO con color..."]}
  ]
}
Tipos válidos: added, improved, fixed, removed, changed (mismos colores/labels
que _ChangeType en Dart). También soporta el formato plano anterior con
"changes": [...] por compatibilidad.
"""

import argparse
import json
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# ── Paleta RetroTheme (modo oscuro) ─────────────────────────────────────────
NAVY = (0x26, 0x2A, 0x38)
CREAM = (0xF2, 0xEF, 0xE4)
TEAL = (0xA7, 0xDE, 0xE1)
AMBER = (0xF2, 0xA9, 0x1E)
RED = (0xE0, 0x48, 0x3A)
SHADOW = (0x14, 0x16, 0x1F)

# ── Tipos de cambio: mismos colores/labels que _ChangeType en el Dart ───────
CHANGE_TYPES = {
    "added":    {"label": "NEW",      "color": (0x22, 0xC5, 0x5E)},  # verde
    "improved": {"label": "IMPROVED", "color": (0x3B, 0x82, 0xF6)},  # azul
    "fixed":    {"label": "FIXED",    "color": (0xF5, 0x9E, 0x0B)},  # ámbar
    "removed":  {"label": "REMOVED",  "color": (0xEF, 0x44, 0x44)},  # rojo
    "changed":  {"label": "CHANGED",  "color": (0x8B, 0x5C, 0xF6)},  # violeta
}

SCRIPT_DIR = Path(__file__).resolve().parent
LOCAL_FONT_DIR = SCRIPT_DIR / "fonts"

# Rutas candidatas para cada fuente: primero la copia local (portable),
# luego rutas típicas de Linux, por si el usuario prefiere las del sistema.
FONT_HEADING_CANDIDATES = [
    LOCAL_FONT_DIR / "DejaVuSansCondensed-Bold.ttf",
    Path("/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-Bold.ttf"),
]
FONT_BODY_CANDIDATES = [
    LOCAL_FONT_DIR / "DejaVuSans-Bold.ttf",
    Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"),
]


def resolve_font_path(candidates) -> str:
    for candidate in candidates:
        if candidate.exists():
            return str(candidate)
    # Último recurso: dejar que Pillow intente resolver por nombre
    # (funciona si fontconfig está instalado y la fuente registrada).
    return "DejaVuSans-Bold.ttf"


FONT_HEADING = resolve_font_path(FONT_HEADING_CANDIDATES)
FONT_BODY = resolve_font_path(FONT_BODY_CANDIDATES)


def load_font(path, size: int) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(str(path), size)
    except OSError as exc:
        raise SystemExit(
            f"No se pudo cargar la fuente '{path}'. "
            f"Asegúrate de que la carpeta 'fonts/' esté junto al script. Detalle: {exc}"
        )


def hard_shadow_rect(draw: ImageDraw.ImageDraw, box, fill, dx=4, dy=4):
    """Rectángulo con sombra dura desplazada (sin blur), la firma del tema."""
    x0, y0, x1, y1 = box
    draw.rectangle((x0 + dx, y0 + dy, x1 + dx, y1 + dy), fill=SHADOW)
    draw.rectangle(box, fill=fill, outline=CREAM, width=2)


def measure_skewed_tag(draw, text, font, pad_x=18, pad_y=10, skew=18):
    """Mismo cálculo de tamaño que draw_skewed_tag, sin pintar nada.
    Devuelve (box_w, box_h, total_w) donde total_w incluye el desfase del skew."""
    bbox = draw.textbbox((0, 0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    box_w, box_h = w + pad_x * 2, h + pad_y * 2
    return box_w, box_h, box_w + skew


def draw_skewed_tag(draw, xy, text, font, fg=NAVY, bg=AMBER, pad_x=18, pad_y=10, skew=18):
    """Aproxima el SkewChip: paralelogramo con texto recto encima."""
    x, y = xy
    bbox = draw.textbbox((0, 0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    box_w, box_h = w + pad_x * 2, h + pad_y * 2

    poly = [
        (x + skew, y),
        (x + box_w + skew, y),
        (x + box_w, y + box_h),
        (x, y + box_h),
    ]
    shadow_poly = [(px + 4, py + 4) for px, py in poly]
    draw.polygon(shadow_poly, fill=SHADOW)
    draw.polygon(poly, fill=bg, outline=CREAM, width=2)
    draw.text((x + pad_x + skew / 2, y + pad_y - bbox[1]), text, font=font, fill=fg)
    return box_w, box_h


def wrap_text(draw, text, font, max_width):
    words = text.split()
    lines, current = [], ""
    for word in words:
        trial = f"{current} {word}".strip()
        if draw.textlength(trial, font=font) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def build_wallpaper(bg_path: Path, data: dict, out_path: Path, max_items_per_group: int = 3):
    img = Image.open(bg_path).convert("RGB")
    draw = ImageDraw.Draw(img)
    W, H = img.size

    margin = int(W * 0.09)
    content_top = int(H * 0.28)
    content_width = W - margin * 2

    f_app = load_font(FONT_HEADING, int(W * 0.045))
    f_version_tag = load_font(FONT_HEADING, int(W * 0.05))  # ligeramente más pequeño
    f_tag_pill = load_font(FONT_HEADING, int(W * 0.032))
    f_date = load_font(FONT_BODY, int(W * 0.032))
    f_group_label = load_font(FONT_HEADING, int(W * 0.034))
    f_item = load_font(FONT_BODY, int(W * 0.034))

    y = content_top

    app_name = data.get("app_name", "")
    version_text = f"V{data['version'].upper()}" if data.get("version") else ""
    status_tag = data.get("tag")

    # Medir tamaños de versión y pill "Latest"
    tag_box_w = tag_box_h = tag_total_w = 0
    pill_w = pill_h = 0
    if version_text:
        tag_box_w, tag_box_h, tag_total_w = measure_skewed_tag(draw, version_text, f_version_tag)
    if status_tag:
        pill_bbox = draw.textbbox((0, 0), status_tag.upper(), font=f_tag_pill)
        pill_w = (pill_bbox[2] - pill_bbox[0]) + 24
        pill_h = int(f_tag_pill.size * 1.7)

    # ── Fila superior: título a la izquierda, pill "Latest" a la derecha ──────
    row_h = max(f_app.size, pill_h)
    title_y = y + (row_h - f_app.size) // 2
    pill_y = y + (row_h - pill_h) // 2

    if app_name:
        draw.text((margin, title_y), app_name.upper(), font=f_app, fill=TEAL)

    if status_tag:
        pill_x = W - margin - pill_w
        draw.rectangle(
            (pill_x + 4, pill_y + 4, pill_x + pill_w + 4, pill_y + pill_h + 4), fill=SHADOW
        )
        draw.rectangle(
            (pill_x, pill_y, pill_x + pill_w, pill_y + pill_h), fill=NAVY, outline=TEAL, width=2
        )
        draw.text(
            (pill_x + 12, pill_y + pill_h / 2 - (pill_bbox[3] - pill_bbox[1]) / 2 - pill_bbox[1]),
            status_tag.upper(),
            font=f_tag_pill,
            fill=TEAL,
        )

    y += row_h + int(H * 0.012)

    # ── Versión: justo debajo del pill "Latest", alineada a la derecha ────────
    if version_text:
        tag_x = W - margin - tag_total_w
        draw_skewed_tag(draw, (tag_x, y), version_text, f_version_tag, fg=NAVY, bg=AMBER)
        y += tag_box_h

    y += int(H * 0.02)

    # Fecha
    if data.get("date"):
        draw.text((margin, y), data["date"], font=f_date, fill=CREAM)
        y += int(f_date.size * 1.6)

    y += int(H * 0.035)

    # ── Grupos de cambios, tipados como en la app (added/improved/fixed/...) ──
    groups = data.get("groups")
    if not groups and data.get("changes"):
        # Compatibilidad con el formato plano anterior
        groups = [{"type": "changed", "items": data["changes"]}]

    dot_r = max(3, int(f_item.size * 0.14))
    text_indent = margin + dot_r * 2 + 14

    for group in groups or []:
        meta = CHANGE_TYPES.get(group.get("type", "changed"), CHANGE_TYPES["changed"])
        items = group.get("items", [])[:max_items_per_group]
        if not items:
            continue

        # Encabezado del grupo, coloreado según el tipo (mismo esquema que Dart)
        draw.rectangle((margin, y + 4, margin + 6, y + f_group_label.size), fill=meta["color"])
        draw.text((margin + 16, y), meta["label"], font=f_group_label, fill=meta["color"])
        y += int(f_group_label.size * 1.5)

        for item in items:
            wrapped = wrap_text(draw, item, f_item, content_width - (text_indent - margin))
            dot_cy = y + int(f_item.size * 0.55)
            draw.ellipse(
                (margin + dot_r, dot_cy - dot_r, margin + dot_r * 3, dot_cy + dot_r),
                fill=CREAM,
            )
            for line in wrapped:
                draw.text((text_indent, y), line, font=f_item, fill=CREAM)
                y += int(f_item.size * 1.4)
            y += int(H * 0.006)

        y += int(H * 0.018)  # espacio entre grupos

    img.save(out_path)
    print(f"Wallpaper guardado en: {out_path}")


def main():
    parser = argparse.ArgumentParser(description="Genera wallpaper con overlay de changelog.")
    parser.add_argument("--bg", required=True, type=Path, help="Ruta al fondo generado por IA")
    parser.add_argument("--data", required=True, type=Path, help="Ruta al JSON con version/changes")
    parser.add_argument("--out", default=Path("wallpaper_out.png"), type=Path, help="Archivo de salida")
    parser.add_argument(
        "--max-items", type=int, default=3,
        help="Máximo de items a mostrar por grupo (el wallpaper es un resumen, no el changelog completo)",
    )
    args = parser.parse_args()

    data = json.loads(args.data.read_text(encoding="utf-8"))
    build_wallpaper(args.bg, data, args.out, max_items_per_group=args.max_items)


if __name__ == "__main__":
    main()
