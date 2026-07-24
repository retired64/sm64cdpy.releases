"""
Fusiona dos capturas de pantalla (ej. modo oscuro y modo claro) usando un
corte diagonal, igual al efecto usado en las capturas de Play Store / F-Droid
para mostrar soporte de ambos temas.

Uso básico (diagonal completa, esquina a esquina, de izquierda a derecha):
    python fusionar_diagonal.py oscuro.png claro.png resultado.png

Elegir el sentido de la diagonal:
    python fusionar_diagonal.py oscuro.png claro.png resultado.png --sentido izq-der
    python fusionar_diagonal.py oscuro.png claro.png resultado.png --sentido der-izq

Controlar qué tan inclinada es la línea (0 = casi vertical, 90 = esquina a esquina):
    python fusionar_diagonal.py oscuro.png claro.png resultado.png --angulo 60

Otras opciones:
    python fusionar_diagonal.py oscuro.png claro.png resultado.png --grosor 6 --color "#FFFFFF"

Por defecto:
- "sentido" izq-der: la imagen1 domina la parte de ARRIBA/IZQUIERDA, la imagen2
  la parte de ABAJO/DERECHA, y la línea "cae" hacia la derecha a medida que baja.
- "sentido" der-izq: es el espejo horizontal del anterior, la línea "cae" hacia
  la izquierda a medida que baja.
- "angulo" 90: la línea va de esquina a esquina (máxima inclinación posible).
  Valores menores acercan la línea a una vertical centrada.
"""

import argparse
from PIL import Image, ImageDraw


def calcular_puntos_linea(size, sentido="izq-der", angulo=90):
    """
    Devuelve los dos puntos (arriba, abajo) que definen la diagonal, según el
    sentido y el ángulo pedidos.

    angulo: 0-90. En 90, la línea recorre todo el ancho de la imagen (esquina
    a esquina). En 0, la línea es vertical y pasa por el centro.
    """
    w, h = size
    angulo = max(0, min(90, angulo))
    offset = (w / 2) * (angulo / 90)
    mid = w / 2

    if sentido == "izq-der":
        x_arriba = mid - offset
        x_abajo = mid + offset
    elif sentido == "der-izq":
        x_arriba = mid + offset
        x_abajo = mid - offset
    else:
        raise ValueError("sentido debe ser 'izq-der' o 'der-izq'")

    return (x_arriba, 0), (x_abajo, h)


def crear_mascara_diagonal(size, punto_arriba, punto_abajo):
    """
    Crea una máscara binaria (L): imagen1 (blanco/255) queda del lado
    izquierdo de la línea que va de punto_arriba a punto_abajo; imagen2
    (negro/0) del lado derecho.
    """
    w, h = size
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)

    x_arriba, _ = punto_arriba
    x_abajo, _ = punto_abajo

    # Trapecio/triángulo a la izquierda de la línea
    draw.polygon([(0, 0), (x_arriba, 0), (x_abajo, h), (0, h)], fill=255)

    return mask


def fusionar(ruta_img1, ruta_img2, ruta_salida, sentido="izq-der", angulo=90,
             grosor_linea=4, color_linea="#FFFFFF"):
    img1 = Image.open(ruta_img1).convert("RGB")
    img2 = Image.open(ruta_img2).convert("RGB")

    # Aseguramos que ambas tengan el mismo tamaño (se ajusta img2 al tamaño de img1)
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)

    size = img1.size
    punto_arriba, punto_abajo = calcular_puntos_linea(size, sentido, angulo)
    mask = crear_mascara_diagonal(size, punto_arriba, punto_abajo)

    resultado = Image.composite(img1, img2, mask)

    if grosor_linea > 0:
        draw = ImageDraw.Draw(resultado)
        draw.line([punto_arriba, punto_abajo], fill=color_linea, width=grosor_linea)

    resultado.save(ruta_salida)
    print(f"Guardado en: {ruta_salida}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fusiona 2 imágenes con corte diagonal")
    parser.add_argument("imagen1", help="Ruta de la imagen 1 (domina arriba/izquierda)")
    parser.add_argument("imagen2", help="Ruta de la imagen 2 (domina abajo/derecha)")
    parser.add_argument("salida", help="Ruta de salida")
    parser.add_argument("--sentido", choices=["izq-der", "der-izq"], default="izq-der",
                         help="Hacia dónde 'cae' la diagonal al bajar (default: izq-der)")
    parser.add_argument("--angulo", type=float, default=90,
                         help="Inclinación de la línea, 0-90 (default: 90, esquina a esquina)")
    parser.add_argument("--grosor", type=int, default=4,
                         help="Grosor de la línea divisoria en px (0 = sin línea)")
    parser.add_argument("--color", default="#FFFFFF",
                         help="Color de la línea divisoria (hex)")
    args = parser.parse_args()

    fusionar(args.imagen1, args.imagen2, args.salida,
              args.sentido, args.angulo, args.grosor, args.color)
