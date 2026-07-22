#!/usr/bin/env python3
"""
fix_mods_structure.py

Convierte database_sm64coopdx.json de:
    "mods": [ {...}, {...}, ... ]
a:
    "mods": { "1": {...}, "2": {...}, ... }

que es el formato que espera el código Dart actual
(LocalModDatasource._parse y fetchRemote hacen
 `data['mods'] as Map<String, dynamic>`).

Uso:
    python fix_mods_structure.py input.json output.json
    python fix_mods_structure.py database_sm64coopdx.json          # sobrescribe el mismo archivo
"""

import json
import sys
from pathlib import Path


def convert(data: dict) -> dict:
    mods = data.get("mods")

    if isinstance(mods, dict):
        # Ya está en el formato correcto, no hay nada que hacer.
        print("El campo 'mods' ya es un objeto (Map). Nada que convertir.")
        return data

    if not isinstance(mods, list):
        raise ValueError(
            f"Se esperaba que 'mods' fuera una lista o un objeto, "
            f"pero es {type(mods).__name__}."
        )

    mods_map = {}
    missing_id_count = 0

    for i, mod in enumerate(mods):
        if not isinstance(mod, dict):
            raise ValueError(f"El elemento en el índice {i} de 'mods' no es un objeto.")

        mod_id = mod.get("id")
        if mod_id is None:
            # Fallback: usar el slug o el índice si no hay id.
            mod_id = mod.get("slug", f"unknown_{i}")
            missing_id_count += 1

        key = str(mod_id)

        if key in mods_map:
            raise ValueError(f"Id duplicado detectado: '{key}'. Revisa el JSON de origen.")

        mods_map[key] = mod

    if missing_id_count:
        print(f"Aviso: {missing_id_count} mods no tenían 'id' y se usó 'slug' o un id generado.")

    data["mods"] = mods_map
    data["mod_count"] = len(mods_map)

    return data


def main():
    if len(sys.argv) not in (2, 3):
        print("Uso: python fix_mods_structure.py <input.json> [output.json]")
        sys.exit(1)

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2]) if len(sys.argv) == 3 else input_path

    if not input_path.exists():
        print(f"Error: no se encontró el archivo '{input_path}'.")
        sys.exit(1)

    with input_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    fixed = convert(data)

    with output_path.open("w", encoding="utf-8") as f:
        json.dump(fixed, f, ensure_ascii=False, indent=2)

    print(f"Listo. {len(fixed.get('mods', {}))} mods escritos en '{output_path}'.")


if __name__ == "__main__":
    main()

