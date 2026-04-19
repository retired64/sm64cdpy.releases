#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║              Android / Flutter Icon Generator  v4.0                        ║
║                                                                              ║
║  Genera automáticamente todos los iconos necesarios para publicar una        ║
║  aplicación Android o Flutter en Google Play Store.                          ║
║                                                                              ║
║  Crea la estructura completa de carpetas mipmap-* con los 4 tipos de         ║
║  imagen requeridos en cada densidad, el XML de adaptive icon y el            ║
║  ícono de 512px para Google Play Store.                                      ║
║                                                                              ║
║  Requisitos:                                                                 ║
║    pip install Pillow                                                        ║
║                                                                              ║
║  Uso rápido:                                                                 ║
║    python3 generate_icons.py --image logo.png --color "#9B59B6"              ║
║                                                                              ║
║  Para ver la ayuda completa:                                                 ║
║    python3 generate_icons.py --help                                          ║
╚══════════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import shutil
import argparse
import textwrap
from pathlib import Path
from datetime import datetime

# ── Verificar Pillow antes de importar ────────────────────────────────────────
try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    print("\n❌ Pillow no está instalado.")
    print("   Instálalo con:\n")
    print("   pip install Pillow\n")
    print("   o en Termux:\n")
    print("   pip install Pillow --break-system-packages\n")
    sys.exit(1)

# ══════════════════════════════════════════════════════════════════════════════
# CONSTANTES
# ══════════════════════════════════════════════════════════════════════════════

VERSION = "4.0"

# Densidades Android con sus tamaños en px
# launcher  → ic_launcher.png          (ícono legacy combinado)
# adaptive  → background/foreground/monochrome (capas adaptive icon)
DENSITIES = {
    "mipmap-mdpi":    {"launcher": 48,  "adaptive": 108},
    "mipmap-hdpi":    {"launcher": 72,  "adaptive": 162},
    "mipmap-xhdpi":   {"launcher": 96,  "adaptive": 216},
    "mipmap-xxhdpi":  {"launcher": 144, "adaptive": 324},
    "mipmap-xxxhdpi": {"launcher": 192, "adaptive": 432},
}

PLAY_STORE_SIZE   = 512    # px — requerido por Google Play
PLAY_STORE_RADIUS = 0.2    # 20% de radio para esquinas redondeadas
PLAY_STORE_PADDING = 0.1   # 10% de padding interior para el logo

# Ruta interna de res/ en un proyecto Flutter/Android estándar
FLUTTER_RES_PATH = os.path.join("android", "app", "src", "main", "res")

# XML del adaptive icon — estructura fija, igual para todas las apps
IC_LAUNCHER_XML = """\
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@mipmap/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
  <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
"""

# ══════════════════════════════════════════════════════════════════════════════
# UTILIDADES
# ══════════════════════════════════════════════════════════════════════════════

def print_banner():
    """Muestra el banner de bienvenida."""
    print(f"""
╔══════════════════════════════════════════════════════╗
║       Android / Flutter Icon Generator  v{VERSION}        ║
╚══════════════════════════════════════════════════════╝
""")


def print_section(title: str):
    """Imprime un separador de sección."""
    print(f"\n── {title} {'─' * (48 - len(title))}")


def hex_to_rgb(hex_color: str) -> tuple:
    """
    Convierte un color HEX a tupla RGB.

    Acepta formatos: #RRGGBB  o  RRGGBB
    Retorna: (R, G, B) como ints 0-255
    Lanza: ValueError si el formato es inválido
    """
    hex_color = hex_color.strip().lstrip("#")
    if len(hex_color) != 6:
        raise ValueError(
            f"Color HEX inválido: '#{hex_color}'\n"
            "   Formato esperado: #RRGGBB  (ej: #9B59B6)"
        )
    try:
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
    except ValueError:
        raise ValueError(
            f"Color HEX inválido: '#{hex_color}'\n"
            "   Solo se permiten caracteres 0-9 y A-F."
        )


def validate_image(path: str) -> Image.Image:
    """
    Valida y carga la imagen fuente.

    Comprueba: existencia, formato PNG, modo RGBA.
    Retorna: Image.Image listo para procesar.
    Lanza: SystemExit si hay algún problema.
    """
    path = os.path.expanduser(path)

    if not os.path.exists(path):
        print(f"❌ No se encontró la imagen: {path}")
        sys.exit(1)

    if not path.lower().endswith(".png"):
        print(f"⚠️  Advertencia: el archivo no tiene extensión .png: {path}")
        print("   Se intentará procesar de todas formas...\n")

    try:
        img = Image.open(path)
    except Exception as e:
        print(f"❌ No se pudo abrir la imagen: {e}")
        sys.exit(1)

    # Convertir a RGBA para garantizar canal alpha
    img = img.convert("RGBA")

    # Advertir si la imagen es muy pequeña (calidad degradada)
    min_recommended = 512
    if img.width < min_recommended or img.height < min_recommended:
        print(f"⚠️  Advertencia: la imagen es pequeña ({img.width}x{img.height}px).")
        print(f"   Se recomienda mínimo {min_recommended}x{min_recommended}px para buena calidad.\n")

    return img


def backup_existing(res_dir: str) -> str | None:
    """
    Si ya existe la carpeta res/, crea un backup antes de sobreescribir.

    Retorna la ruta del backup o None si no había nada que respaldar.
    """
    if not os.path.exists(res_dir):
        return None

    # Verificar si contiene archivos de icono (no hacer backup de carpetas vacías)
    has_icons = any(
        fname.startswith("ic_launcher")
        for _, _, files in os.walk(res_dir)
        for fname in files
    )
    if not has_icons:
        return None

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = f"{res_dir}_backup_{timestamp}"

    # Solo respaldar las carpetas mipmap-*, no toda res/ para no perder otros recursos
    backup_mipmap = os.path.join(backup_path, "mipmap_backup")
    os.makedirs(backup_mipmap, exist_ok=True)

    for density in DENSITIES:
        src = os.path.join(res_dir, density)
        if os.path.exists(src):
            shutil.copytree(src, os.path.join(backup_mipmap, density))

    # También respaldar el XML
    xml_src = os.path.join(res_dir, "mipmap-anydpi-v26", "ic_launcher.xml")
    if os.path.exists(xml_src):
        xml_dst_dir = os.path.join(backup_mipmap, "mipmap-anydpi-v26")
        os.makedirs(xml_dst_dir, exist_ok=True)
        shutil.copy2(xml_src, xml_dst_dir)

    return backup_path


# ══════════════════════════════════════════════════════════════════════════════
# GENERADORES DE IMÁGENES
# ══════════════════════════════════════════════════════════════════════════════

def create_background(size: int, color_rgb: tuple) -> Image.Image:
    """
    Crea el fondo de color sólido para el adaptive icon.

    El fondo es siempre opaco (alpha=255) en el color especificado.
    """
    return Image.new("RGBA", (size, size), (*color_rgb, 255))


def create_foreground(source: Image.Image, size: int) -> Image.Image:
    """
    Escala el logo y lo centra sobre un canvas transparente.

    Respeta la proporción original del logo (thumbnail no estira).
    El canvas resultante tiene fondo completamente transparente
    para que el adaptive icon muestre el background detrás.
    """
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    src = source.copy()
    src.thumbnail((size, size), Image.LANCZOS)
    offset_x = (size - src.width) // 2
    offset_y = (size - src.height) // 2
    canvas.paste(src, (offset_x, offset_y), src)
    return canvas


def create_monochrome(source: Image.Image, size: int) -> Image.Image:
    """
    Genera la versión monocromática real del ícono para Android 13+ themed icons.

    El themed icons de Android toma esta capa y la tiñe con el color
    del sistema (del wallpaper del usuario), permitiendo que todos los
    íconos del launcher combinen visualmente.

    Técnica correcta:
      1. Convertir RGB a escala de grises reales (modo "L" = Luminance),
         preservando los tonos oscuros y claros de la imagen original.
         La versión anterior pintaba todo blanco plano — esto lo corrige.
      2. Convertir el gris a RGBA para poder manejar transparencia.
      3. Restaurar el canal alpha original de la imagen fuente,
         para que las zonas transparentes sigan siéndolo.
      4. Centrar sobre canvas transparente del tamaño de densidad correcto.

    Resultado: imagen en blanco/negro/grises con transparencia intacta,
    lista para que Android la tina con el color del sistema del usuario.
    """
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # Trabajar con copia RGBA para extraer el alpha original
    src_rgba = source.copy().convert("RGBA")
    src_rgba.thumbnail((size, size), Image.LANCZOS)

    # Guardar canal alpha antes de convertir a grises
    _, _, _, alpha = src_rgba.split()

    # Convertir a escala de grises real (luminosidad, no blanco plano)
    src_gray = src_rgba.convert("L")       # modo L = Luminance

    # Volver a RGBA para poder asignar el alpha
    src_gray_rgba = src_gray.convert("RGBA")

    # Restaurar transparencia original
    src_gray_rgba.putalpha(alpha)

    # Centrar en el canvas
    offset_x = (size - src_gray_rgba.width) // 2
    offset_y = (size - src_gray_rgba.height) // 2
    canvas.paste(src_gray_rgba, (offset_x, offset_y), src_gray_rgba)

    return canvas


def create_combined_launcher(
    bg: Image.Image,
    fg: Image.Image,
    size: int
) -> Image.Image:
    """
    Combina background + foreground para el ic_launcher.png legacy.

    Este archivo es el que usan dispositivos con Android < 8.0 (API 26)
    que no soportan adaptive icons. Es la "foto final" del ícono.
    """
    # Redimensionar el background al tamaño final del launcher
    combined = bg.copy().resize((size, size), Image.LANCZOS).convert("RGBA")
    # Redimensionar el foreground y compositar encima
    fg_sized = fg.copy().resize((size, size), Image.LANCZOS).convert("RGBA")
    combined.paste(fg_sized, (0, 0), fg_sized)
    return combined


def create_play_store_icon(
    source: Image.Image,
    color_rgb: tuple,
    size: int = PLAY_STORE_SIZE
) -> Image.Image:
    """
    Genera el ícono de 512x512px para Google Play Store.

    Google Play requiere una imagen cuadrada de exactamente 512x512px.
    Aplica esquinas redondeadas (20% de radio) siguiendo las guías de
    Material Design para íconos de apps en el Store.

    El logo se coloca centrado con un 10% de padding interno para
    que no quede pegado a los bordes.
    """
    # Canvas transparente
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # Máscara con esquinas redondeadas
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    radius = int(size * PLAY_STORE_RADIUS)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)

    # Fondo de color aplicado con la máscara
    bg_layer = Image.new("RGBA", (size, size), (*color_rgb, 255))
    canvas.paste(bg_layer, mask=mask)

    # Logo centrado con padding
    logo = source.copy()
    padding = int(size * PLAY_STORE_PADDING)
    max_logo_size = size - (padding * 2)
    logo.thumbnail((max_logo_size, max_logo_size), Image.LANCZOS)

    offset_x = (size - logo.width) // 2
    offset_y = (size - logo.height) // 2
    canvas.paste(logo, (offset_x, offset_y), logo)

    return canvas


# ══════════════════════════════════════════════════════════════════════════════
# FUNCIÓN PRINCIPAL
# ══════════════════════════════════════════════════════════════════════════════

def generate_icons(
    image_path: str,
    color_hex: str,
    res_dir: str,
    play_store_dir: str,
    no_backup: bool = False,
    no_play_store: bool = False,
    verbose: bool = False,
) -> bool:
    """
    Genera todos los íconos Android/Flutter necesarios.

    Args:
        image_path:     Ruta al PNG fuente (con fondo transparente).
        color_hex:      Color de fondo en formato HEX (#RRGGBB).
        res_dir:        Directorio destino para la carpeta res/.
        play_store_dir: Directorio donde guardar play_store_512.png.
        no_backup:      Si True, no crear backup de íconos existentes.
        no_play_store:  Si True, no generar el ícono de Play Store.
        verbose:        Si True, mostrar información extra.

    Returns:
        True si todo fue exitoso, False si hubo algún error.
    """

    # ── Validaciones ──────────────────────────────────────────────────────────
    print_section("Validando entrada")

    try:
        color_rgb = hex_to_rgb(color_hex)
    except ValueError as e:
        print(f"❌ {e}")
        return False

    source = validate_image(image_path)

    print(f"  ✅ Imagen  : {os.path.abspath(image_path)} ({source.width}x{source.height}px)")
    print(f"  🎨 Color   : {color_hex.upper()} → RGB{color_rgb}")
    print(f"  📂 Destino : {os.path.abspath(res_dir)}")

    # ── Backup ────────────────────────────────────────────────────────────────
    if not no_backup:
        backup = backup_existing(res_dir)
        if backup:
            print(f"\n  💾 Backup creado en: {backup}")

    # ── XML ───────────────────────────────────────────────────────────────────
    print_section("Generando archivos")

    xml_dir = os.path.join(res_dir, "mipmap-anydpi-v26")
    os.makedirs(xml_dir, exist_ok=True)

    xml_path = os.path.join(xml_dir, "ic_launcher.xml")
    with open(xml_path, "w", encoding="utf-8") as f:
        f.write(IC_LAUNCHER_XML)
    print(f"  📄 mipmap-anydpi-v26/ic_launcher.xml")

    # ── Íconos por densidad ───────────────────────────────────────────────────
    total_files = 0
    errors = []

    for density, sizes in DENSITIES.items():
        folder = os.path.join(res_dir, density)
        os.makedirs(folder, exist_ok=True)

        adaptive_size = sizes["adaptive"]
        launcher_size = sizes["launcher"]

        try:
            bg       = create_background(adaptive_size, color_rgb)
            fg       = create_foreground(source, adaptive_size)
            mono     = create_monochrome(source, adaptive_size)
            combined = create_combined_launcher(bg, fg, launcher_size)

            bg.save(      os.path.join(folder, "ic_launcher_background.png"),  optimize=True)
            fg.save(      os.path.join(folder, "ic_launcher_foreground.png"),  optimize=True)
            mono.save(    os.path.join(folder, "ic_launcher_monochrome.png"),  optimize=True)
            combined.save(os.path.join(folder, "ic_launcher.png"),             optimize=True)

            total_files += 4

            if verbose:
                print(f"  📁 {density:<22} launcher:{launcher_size}px  adaptive:{adaptive_size}px")
            else:
                print(f"  📁 {density}")

        except Exception as e:
            errors.append(f"{density}: {e}")
            print(f"  ❌ Error en {density}: {e}")

    # ── Play Store ────────────────────────────────────────────────────────────
    if not no_play_store:
        try:
            os.makedirs(play_store_dir, exist_ok=True)
            play_store = create_play_store_icon(source, color_rgb, PLAY_STORE_SIZE)
            play_store_path = os.path.join(play_store_dir, "play_store_512.png")
            play_store.save(play_store_path, optimize=True)
            total_files += 1
            print(f"  🏪 play_store_512.png  (512x512px)")
        except Exception as e:
            errors.append(f"play_store_512.png: {e}")
            print(f"  ❌ Error generando Play Store icon: {e}")

    # ── Resumen ───────────────────────────────────────────────────────────────
    print_section("Resumen")

    if errors:
        print(f"  ⚠️  Completado con {len(errors)} error(es):")
        for err in errors:
            print(f"     • {err}")
    else:
        print(f"  ✅ {total_files} archivos generados sin errores")

    print(f"\n  Estructura generada en:")
    print(f"  {os.path.abspath(res_dir)}\n")

    # Mostrar árbol de carpetas creadas
    _print_tree(res_dir, play_store_dir, no_play_store)

    return len(errors) == 0


def _print_tree(res_dir: str, play_store_dir: str, no_play_store: bool):
    """Imprime un árbol visual de los archivos generados."""
    base = os.path.dirname(res_dir) if os.path.basename(res_dir) == "res" else res_dir

    entries = []
    if not no_play_store:
        ps_path = os.path.join(play_store_dir, "play_store_512.png")
        if os.path.exists(ps_path):
            entries.append(("play_store_512.png", False))

    entries.append(("res/", True))

    for entry, is_dir in entries:
        print(f"  {'📁' if is_dir else '🖼 '} {entry}")

    subdirs = ["mipmap-anydpi-v26"] + list(DENSITIES.keys())
    for i, subdir in enumerate(subdirs):
        is_last_dir = (i == len(subdirs) - 1)
        prefix = "  └──" if is_last_dir else "  ├──"
        print(f"  {prefix} {subdir}/")

        # Listar archivos dentro
        full_path = os.path.join(res_dir, subdir)
        if os.path.exists(full_path):
            files = sorted(os.listdir(full_path))
            for j, fname in enumerate(files):
                is_last_file = (j == len(files) - 1)
                file_prefix = "       └── " if is_last_file else "       ├── "
                print(f"  {file_prefix}{fname}")
    print()


# ══════════════════════════════════════════════════════════════════════════════
# CLI
# ══════════════════════════════════════════════════════════════════════════════

EXAMPLES = textwrap.dedent("""\
Ejemplos de uso:
  ──────────────────────────────────────────────────────────────────

  Modo básico — genera res/ en el directorio actual:
    python3 generate_icons.py --image logo.png --color "#9B59B6"

  Modo Flutter — reemplaza íconos directamente en el proyecto:
    python3 generate_icons.py --image logo.png --color "#E74C3C" --project ~/MiApp

  Carpeta de salida personalizada:
    python3 generate_icons.py --image logo.png --color "#2ECC71" --output ~/output

  Sin generar ícono de Play Store:
    python3 generate_icons.py --image logo.png --color "#3498DB" --no-play-store

  Sin hacer backup de íconos existentes:
    python3 generate_icons.py --image logo.png --color "#E67E22" --no-backup

  Salida detallada con tamaños:
    python3 generate_icons.py --image logo.png --color "#1ABC9C" --verbose

  ──────────────────────────────────────────────────────────────────

Colores de ejemplo:
    Morado   →  #9B59B6      Rojo     →  #E74C3C
    Azul     →  #3498DB      Verde    →  #2ECC71
    Naranja  →  #E67E22      Negro    →  #1A1A1A
    Turquesa →  #1ABC9C      Rosa     →  #E91E63

  ──────────────────────────────────────────────────────────────────

Archivos generados:
    res/mipmap-anydpi-v26/ic_launcher.xml       ← XML adaptive icon
    res/mipmap-{densidad}/ic_launcher.png        ← ícono legacy (Android <8)
    res/mipmap-{densidad}/ic_launcher_background.png  ← capa fondo
    res/mipmap-{densidad}/ic_launcher_foreground.png  ← capa logo
    res/mipmap-{densidad}/ic_launcher_monochrome.png  ← themed icons (Android 13+)
    play_store_512.png                           ← ícono para Google Play

  Densidades generadas: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi

  ──────────────────────────────────────────────────────────────────

Requisitos:
    Python 3.8+  |  pip install Pillow
""")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="generate_icons.py",
        description="Generador de íconos Android / Flutter — v" + VERSION,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=EXAMPLES,
    )

    # ── Argumentos principales ────────────────────────────────────────────────
    required = parser.add_argument_group("argumentos requeridos")
    required.add_argument(
        "--image", "-i",
        required=True,
        metavar="RUTA",
        help="Ruta al archivo PNG fuente (con fondo transparente recomendado)."
    )
    required.add_argument(
        "--color", "-c",
        required=True,
        metavar="HEX",
        help="Color de fondo en formato HEX. Ejemplo: '#9B59B6' o '9B59B6'."
    )

    # ── Destino ────────────────────────────────────────────────────────────────
    dest = parser.add_argument_group("destino (usar solo uno)")
    dest_group = dest.add_mutually_exclusive_group()
    dest_group.add_argument(
        "--project", "-p",
        metavar="RUTA",
        default=None,
        help=(
            "Raíz del proyecto Flutter. El script escribe directamente en\n"
            f"  <proyecto>/{FLUTTER_RES_PATH}/\n"
            "  Ideal para actualizar íconos sin copiar archivos manualmente."
        )
    )
    dest_group.add_argument(
        "--output", "-o",
        metavar="RUTA",
        default=None,
        help=(
            "Carpeta de salida personalizada. Se creará res/ dentro de ella.\n"
            "  Si no se especifica, se usa el directorio actual."
        )
    )

    # ── Opciones ───────────────────────────────────────────────────────────────
    options = parser.add_argument_group("opciones")
    options.add_argument(
        "--no-backup",
        action="store_true",
        default=False,
        help="No crear backup de los íconos existentes antes de reemplazarlos."
    )
    options.add_argument(
        "--no-play-store",
        action="store_true",
        default=False,
        help="No generar el archivo play_store_512.png."
    )
    options.add_argument(
        "--verbose", "-v",
        action="store_true",
        default=False,
        help="Mostrar información detallada (tamaños de cada archivo generado)."
    )
    options.add_argument(
        "--version",
        action="version",
        version=f"%(prog)s v{VERSION}"
    )

    return parser


def main():
    print_banner()
    parser = build_parser()
    args = parser.parse_args()

    # ── Resolver rutas de destino ─────────────────────────────────────────────
    if args.project:
        project_path = Path(args.project).expanduser().resolve()
        res_dir = str(project_path / FLUTTER_RES_PATH)
        play_store_dir = str(project_path)

        if not os.path.exists(res_dir):
            print(f"❌ No se encontró la ruta de recursos del proyecto:")
            print(f"   {res_dir}")
            print()
            print("   Verifica que:")
            print("   • La ruta apunte a la raíz del proyecto Flutter/Android")
            print(f"   • Exista la carpeta: {FLUTTER_RES_PATH}")
            sys.exit(1)

        print(f"  🚀 Modo     : Flutter / Android nativo")
        print(f"  📦 Proyecto : {project_path}")

    else:
        base_dir = Path(args.output).expanduser().resolve() if args.output else Path.cwd()
        res_dir = str(base_dir / "res")
        play_store_dir = str(base_dir)

        print(f"  🚀 Modo     : Salida estándar")
        print(f"  📂 Base     : {base_dir}")

    # ── Ejecutar generación ───────────────────────────────────────────────────
    success = generate_icons(
        image_path=args.image,
        color_hex=args.color,
        res_dir=res_dir,
        play_store_dir=play_store_dir,
        no_backup=args.no_backup,
        no_play_store=args.no_play_store,
        verbose=args.verbose,
    )

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
