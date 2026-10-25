#!/usr/bin/env python3
"""Add cached, offline translations to a generated SM64CDPY catalogue.

This is deliberately independent from the scraper. It consumes its completed
JSON, preserves the English description and writes a new catalogue atomically.
Argos models are downloaded only when --download-models is explicitly used.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sqlite3
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable, Protocol

SUPPORTED_LOCALES = {"es": "es", "pt_BR": "pt", "fr": "fr", "it": "it"}
ENGINE_ID = "argos-translate-2"
TRANSLATION_ATTEMPTS = 3
TOKEN_RE = re.compile(r"ZXQPROTECTED(\d{4})QXZ")
PROTECTED_RE = re.compile(
    r"```.*?```|`[^`\n]+`|https?://[^\s<>]+|"
    r"\b(?:SM64CoopDX|SM64CDPY|DynOS|Lua|ROM|WebRTC|Discord|GitHub|YouTube)\b|"
    r"(?:[\w.-]+/)+[\w.-]+|\b[\w.-]+\.(?:zip|lua|json|txt|ini|cfg|z64|n64)\b",
    re.IGNORECASE | re.DOTALL,
)
LIST_PREFIX_RE = re.compile(r"^(\s*(?:[-*•]|\d+[.)])\s+)(.*)$", re.DOTALL)


class TranslationError(RuntimeError):
    pass


class Translator(Protocol):
    def translate(self, text: str) -> str: ...


def description_hash(text: str) -> str:
    return "sha256:" + hashlib.sha256(text.encode("utf-8")).hexdigest()


def canonical_mods_id(mods: list[dict]) -> str:
    payload = json.dumps(
        mods, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return "sha256:" + hashlib.sha256(payload).hexdigest()


def _protect(text: str) -> tuple[str, list[str]]:
    values: list[str] = []

    def replace(match: re.Match[str]) -> str:
        values.append(match.group(0))
        return f"ZXQPROTECTED{len(values) - 1:04d}QXZ"

    return PROTECTED_RE.sub(replace, text), values


def _chunks(text: str, maximum: int = 850) -> list[str]:
    if len(text) <= maximum:
        return [text]
    sentences = re.split(r"(?<=[.!?])\s+", text)
    chunks: list[str] = []
    current = ""
    for sentence in sentences:
        if len(sentence) > maximum:
            words = sentence.split()
            for word in words:
                candidate = f"{current} {word}".strip()
                if current and len(candidate) > maximum:
                    chunks.append(current)
                    current = word
                else:
                    current = candidate
            continue
        candidate = f"{current} {sentence}".strip()
        if current and len(candidate) > maximum:
            chunks.append(current)
            current = sentence
        else:
            current = candidate
    if current:
        chunks.append(current)
    return chunks


def _translate_plain_fragment(text: str, translator: Translator) -> str:
    """Translate prose while retaining whitespace adjacent to protected spans."""
    if not text or not text.strip():
        return text
    leading = text[: len(text) - len(text.lstrip())]
    trailing = text[len(text.rstrip()) :]
    core = text.strip()
    # Rules, emoji-only lines and other decoration are presentation, not prose.
    # Passing them to Argos legitimately produces an empty result.
    if not any(character.isalpha() for character in core):
        return text

    translated_chunks: list[str] = []
    for chunk in _chunks(core):
        last_error: Exception | None = None
        translated = ""
        for attempt in range(1, TRANSLATION_ATTEMPTS + 1):
            try:
                translated = translator.translate(chunk).strip()
                if translated:
                    break
                last_error = TranslationError("el motor devolvió texto vacío")
            except Exception as exc:  # third-party model/runtime boundary
                last_error = exc
            if attempt < TRANSLATION_ATTEMPTS:
                time.sleep(0.15 * attempt)
        if not translated:
            preview = chunk.replace("\n", " ")[:120]
            raise TranslationError(
                f"falló tras {TRANSLATION_ATTEMPTS} intentos para {preview!r}: "
                f"{last_error}"
            )
        translated_chunks.append(translated)
    translated = " ".join(translated_chunks)
    return leading + translated + trailing


def _translate_protected_body(
    body: str, values: list[str], translator: Translator
) -> tuple[str, set[int]]:
    """Never expose protected values or their placeholders to the MT engine."""
    output: list[str] = []
    cursor = 0
    found: set[int] = set()
    for match in TOKEN_RE.finditer(body):
        output.append(_translate_plain_fragment(body[cursor : match.start()], translator))
        index = int(match.group(1))
        if index >= len(values):
            raise TranslationError(f"Marcador protegido fuera de rango: {index}")
        output.append(values[index])
        found.add(index)
        cursor = match.end()
    output.append(_translate_plain_fragment(body[cursor:], translator))
    return "".join(output), found


def translate_description(text: str, translator: Translator) -> str:
    """Translate prose while preserving paragraphs, bullets and technical spans."""
    protected, values = _protect(text)
    output: list[str] = []
    restored: set[int] = set()
    for line in protected.splitlines():
        if not line.strip():
            output.append("")
            continue
        match = LIST_PREFIX_RE.match(line)
        prefix, body = (match.group(1), match.group(2)) if match else ("", line)
        translated, line_restored = _translate_protected_body(body, values, translator)
        restored.update(line_restored)
        output.append(prefix + translated)
    expected = set(range(len(values)))
    if restored != expected:
        raise TranslationError(
            f"No se restauraron todos los valores protegidos: "
            f"esperados={expected}, restaurados={restored}"
        )
    return "\n".join(output)


class TranslationCache:
    def __init__(self, path: Path):
        path.parent.mkdir(parents=True, exist_ok=True)
        self.connection = sqlite3.connect(path)
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS translations (
                source_hash TEXT NOT NULL,
                locale TEXT NOT NULL,
                engine TEXT NOT NULL,
                translated_text TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                PRIMARY KEY (source_hash, locale, engine)
            )
            """
        )

    def get(self, source_hash: str, locale: str) -> str | None:
        row = self.connection.execute(
            "SELECT translated_text FROM translations "
            "WHERE source_hash = ? AND locale = ? AND engine = ?",
            (source_hash, locale, ENGINE_ID),
        ).fetchone()
        return row[0] if row else None

    def put(self, source_hash: str, locale: str, text: str) -> None:
        self.connection.execute(
            "INSERT OR REPLACE INTO translations VALUES (?, ?, ?, ?, ?)",
            (
                source_hash,
                locale,
                ENGINE_ID,
                text,
                datetime.now(timezone.utc).isoformat(),
            ),
        )
        self.connection.commit()

    def close(self) -> None:
        self.connection.close()


class ArgosTranslator:
    def __init__(self, target_code: str, download_models: bool):
        try:
            import argostranslate.package as package
            import argostranslate.translate as translate
        except ImportError as exc:
            raise TranslationError(
                "Falta Argos Translate; instala scripts/catalog_translation_requirements.txt"
            ) from exc

        installed = package.get_installed_packages()
        if not any(
            item.from_code == "en" and item.to_code == target_code
            for item in installed
        ):
            if not download_models:
                raise TranslationError(
                    f"Falta el modelo en->{target_code}; usa --download-models"
                )
            package.update_package_index()
            available = package.get_available_packages()
            model = next(
                (
                    item
                    for item in available
                    if item.from_code == "en" and item.to_code == target_code
                ),
                None,
            )
            if model is None:
                raise TranslationError(f"Argos no ofrece el modelo en->{target_code}")
            package.install_from_path(model.download())

        self._translator = translate.get_translation_from_codes("en", target_code)
        if self._translator is None:
            raise TranslationError(f"No se pudo inicializar en->{target_code}")

    def translate(self, text: str) -> str:
        return self._translator.translate(text)


def translate_catalog(
    catalog: dict,
    locales: list[str],
    cache: TranslationCache,
    translator_factory: Callable[[str], Translator],
    progress: Callable[[str], None] = print,
) -> dict:
    mods = catalog.get("mods")
    if not isinstance(mods, list) or not mods:
        raise TranslationError("El catálogo debe contener una lista 'mods' no vacía")
    unknown = set(locales) - SUPPORTED_LOCALES.keys()
    if unknown:
        raise TranslationError(f"Locales no compatibles: {sorted(unknown)}")

    output = json.loads(json.dumps(catalog, ensure_ascii=False))
    source_catalog_id = str(catalog.get("catalog_id", ""))
    translators = {locale: translator_factory(locale) for locale in locales}
    cache_hits = translated = 0

    for index, mod in enumerate(output["mods"], start=1):
        description = mod.get("description")
        if not isinstance(description, str):
            raise TranslationError(f"mod {mod.get('id')}: description no es texto")
        source_hash = description_hash(description)
        translations: dict[str, str] = {locale: "" for locale in locales}
        if description.strip():
            for locale in locales:
                cached = cache.get(source_hash, locale)
                if cached is not None:
                    translations[locale] = cached
                    cache_hits += 1
                    continue
                try:
                    value = translate_description(description, translators[locale])
                except TranslationError as exc:
                    raise TranslationError(
                        f"mod {mod.get('id')} ({mod.get('name')}), locale {locale}: {exc}"
                    ) from exc
                cache.put(source_hash, locale, value)
                translations[locale] = value
                translated += 1
        mod["description_source_hash"] = source_hash
        mod["description_translations"] = translations
        if index == 1 or index % 25 == 0 or index == len(output["mods"]):
            progress(f"Procesados {index}/{len(output['mods'])} mods")

    output["translation_metadata"] = {
        "schema_version": 1,
        "source_language": "en",
        "target_locales": locales,
        "engine": ENGINE_ID,
        "source_catalog_id": source_catalog_id,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "cache_hits": cache_hits,
        "translations_created": translated,
    }
    output["catalog_id"] = canonical_mods_id(output["mods"])
    return output


def _load(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise TranslationError(f"No se pudo leer {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise TranslationError("La raíz del catálogo debe ser un objeto")
    return value


def _write_atomic(path: Path, value: dict, indent: int | None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(value, ensure_ascii=False, indent=indent) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument(
        "--locales", default="es,pt_BR,fr,it", help="Lista separada por comas"
    )
    parser.add_argument(
        "--cache", type=Path, default=Path(".cache/catalog-translations.sqlite3")
    )
    parser.add_argument("--download-models", action="store_true")
    parser.add_argument("--compact", action="store_true")
    args = parser.parse_args(argv)
    locales = [item.strip() for item in args.locales.split(",") if item.strip()]
    cache = TranslationCache(args.cache)
    try:
        result = translate_catalog(
            _load(args.input),
            locales,
            cache,
            lambda locale: ArgosTranslator(
                SUPPORTED_LOCALES[locale], args.download_models
            ),
        )
        _write_atomic(args.output, result, None if args.compact else 2)
    except TranslationError as exc:
        print(f"TRANSLATION ERROR: {exc}", file=sys.stderr)
        return 1
    finally:
        cache.close()
    print(f"Catálogo traducido: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
