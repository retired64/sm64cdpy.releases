#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Analizador de categorías (tags) para database_sm64coopdx.json

✔ Cuenta cuántos mods hay por categoría
✔ Ordena por popularidad
✔ Detecta categorías únicas
✔ Exporta a CSV (opcional)
✔ Maneja JSON grande sin romperse
"""

import json
import os
import sys
from collections import Counter
from pathlib import Path


def find_json_file():
    """Busca automáticamente un JSON en el directorio actual."""
    json_files = list(Path(".").glob("*.json"))

    if not json_files:
        print("❌ No se encontró ningún archivo JSON en este directorio.")
        sys.exit(1)

    if len(json_files) == 1:
        return json_files[0]

    print("📂 Se encontraron múltiples JSON:")
    for i, f in enumerate(json_files):
        print(f"  [{i}] {f}")

    idx = int(input("Selecciona el índice: "))
    return json_files[idx]


def load_data(json_path):
    """Carga el JSON de forma segura."""
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data
    except Exception as e:
        print(f"❌ Error cargando JSON: {e}")
        sys.exit(1)


def extract_categories(data):
    """Extrae y cuenta categorías."""
    counter = Counter()
    total_mods = 0

    mods = data.get("mods", {})

    for mod_id, mod in mods.items():
        tags = mod.get("tags", [])

        if not isinstance(tags, list):
            continue

        for tag in tags:
            tag_clean = tag.strip()
            if tag_clean:
                counter[tag_clean] += 1

        total_mods += 1

    return counter, total_mods


def print_results(counter, total_mods):
    """Muestra resultados en consola."""
    print("\n" + "=" * 50)
    print("📊 ANÁLISIS DE CATEGORÍAS")
    print("=" * 50)

    print(f"\n📦 Total de mods analizados: {total_mods}")
    print(f"🏷️ Categorías únicas: {len(counter)}\n")

    print("🔥 Top categorías:\n")

    for tag, count in counter.most_common():
        print(f"{tag:<25} → {count} mods")

    print("\n" + "=" * 50)


def export_csv(counter):
    """Exporta resultados a CSV."""
    import csv

    output_file = "categories_analysis.csv"

    with open(output_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Category", "Count"])

        for tag, count in counter.most_common():
            writer.writerow([tag, count])

    print(f"\n💾 Exportado a: {output_file}")


def main():
    print("🔍 Buscando archivo JSON...\n")

    json_path = find_json_file()
    print(f"✅ Usando: {json_path}\n")

    data = load_data(json_path)

    counter, total_mods = extract_categories(data)

    if not counter:
        print("⚠️ No se encontraron categorías (tags).")
        return

    print_results(counter, total_mods)

    # Preguntar si exportar
    choice = input("\n¿Exportar a CSV? (s/n): ").lower()
    if choice == "s":
        export_csv(counter)


if __name__ == "__main__":
    main()
