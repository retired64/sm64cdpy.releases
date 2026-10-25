#!/usr/bin/env python3
"""Validate translated catalogue integrity and future Flutter compatibility."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

CATALOG_ID_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
URL_RE = re.compile(r"https?://[^\s<>]+")
TOKEN_RE = re.compile(r"ZXQPROTECTED\d{4}QXZ")


class ValidationError(ValueError):
    pass


def _load(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValidationError(f"No se pudo leer {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise ValidationError(f"{path}: la raíz debe ser un objeto")
    return value


def _hash(text: str) -> str:
    return "sha256:" + hashlib.sha256(text.encode("utf-8")).hexdigest()


def _catalog_id(mods: list) -> str:
    payload = json.dumps(
        mods, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return "sha256:" + hashlib.sha256(payload).hexdigest()


def validate(path: Path, source_path: Path, locales: list[str]) -> dict[str, int]:
    translated = _load(path)
    source = _load(source_path)
    mods = translated.get("mods")
    source_mods = source.get("mods")
    if not isinstance(mods, list) or not isinstance(source_mods, list):
        raise ValidationError("Ambos catálogos deben contener una lista mods")
    if len(mods) != len(source_mods) or translated.get("mod_count") != len(mods):
        raise ValidationError("La traducción alteró la cantidad de mods")
    for key, value in source.items():
        if key not in {"catalog_id", "mods", "translation_metadata"}:
            if translated.get(key) != value:
                raise ValidationError(f"El campo raíz {key!r} fue alterado")

    metadata = translated.get("translation_metadata")
    if not isinstance(metadata, dict) or metadata.get("schema_version") != 1:
        raise ValidationError("Falta translation_metadata schema_version=1")
    if metadata.get("source_language") != "en":
        raise ValidationError("source_language debe ser en")
    if metadata.get("target_locales") != locales:
        raise ValidationError("target_locales no coincide con los locales solicitados")
    if metadata.get("source_catalog_id") != source.get("catalog_id"):
        raise ValidationError("source_catalog_id no coincide con el catálogo original")
    if "en" in locales or len(set(locales)) != len(locales):
        raise ValidationError("Los locales deben ser únicos y no incluir inglés")

    translated_count = 0
    total_chars = 0
    for original, result in zip(source_mods, mods, strict=True):
        if original.get("id") != result.get("id"):
            raise ValidationError("El orden o ID de los mods fue alterado")
        clean = {
            key: value
            for key, value in result.items()
            if key not in {"description_source_hash", "description_translations"}
        }
        if clean != original:
            raise ValidationError(f"mod {original.get('id')}: cambió contenido original")
        description = original.get("description")
        if not isinstance(description, str):
            raise ValidationError(f"mod {original.get('id')}: description inválida")
        if result.get("description_source_hash") != _hash(description):
            raise ValidationError(f"mod {original.get('id')}: hash de descripción inválido")
        translations = result.get("description_translations")
        if not isinstance(translations, dict) or list(translations) != locales:
            raise ValidationError(f"mod {original.get('id')}: locales incompletos")
        for locale, text in translations.items():
            if not isinstance(text, str) or (description.strip() and not text.strip()):
                raise ValidationError(
                    f"mod {original.get('id')}/{locale}: traducción vacía"
                )
            if TOKEN_RE.search(text):
                raise ValidationError(
                    f"mod {original.get('id')}/{locale}: marcador sin restaurar"
                )
            missing_urls = set(URL_RE.findall(description)) - set(URL_RE.findall(text))
            if missing_urls:
                raise ValidationError(
                    f"mod {original.get('id')}/{locale}: URLs perdidas {missing_urls}"
                )
            if description.strip():
                translated_count += 1
                total_chars += len(text)

    catalog_id = translated.get("catalog_id")
    if not isinstance(catalog_id, str) or not CATALOG_ID_RE.fullmatch(catalog_id):
        raise ValidationError("catalog_id traducido tiene formato inválido")
    if catalog_id != _catalog_id(mods):
        raise ValidationError("catalog_id no coincide con el contenido traducido")
    return {"mods": len(mods), "translations": translated_count, "chars": total_chars}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("catalog", type=Path)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--locales", default="es,pt_BR,fr,it")
    args = parser.parse_args(argv)
    locales = [item.strip() for item in args.locales.split(",") if item.strip()]
    try:
        stats = validate(args.catalog, args.source, locales)
    except ValidationError as exc:
        print(f"VALIDATION ERROR: {exc}", file=sys.stderr)
        return 1
    print(
        f"Catálogo compatible: {stats['mods']} mods, "
        f"{stats['translations']} traducciones, {stats['chars']} caracteres"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
