import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def load_script(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


translate = load_script("precompute_catalog_translations")
validate = load_script("validate_translated_catalog")


class FakeTranslator:
    def __init__(self, locale):
        self.locale = locale

    def translate(self, text):
        return f"[{self.locale}] {text}"


def catalog():
    mods = [
        {
            "id": 7,
            "name": "Example",
            "description": "Open `config.txt` at https://example.com.\n\n• Use Lua safely.",
            "versions": [],
        }
    ]
    return {
        "schema_version": 2,
        "catalog_id": translate.canonical_mods_id(mods),
        "catalog_status": "complete",
        "generated_at": "2026-10-25T00:00:00+00:00",
        "source": "https://mods.sm64coopdx.com/",
        "mod_count": 1,
        "resolution_summary": {
            "versions_total": 0,
            "versions_resolved": 0,
            "versions_unresolved": 0,
            "mods_failed": 0,
        },
        "mods": mods,
    }


class CatalogTranslationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_translation_preserves_source_and_protected_content(self):
        cache = translate.TranslationCache(self.root / "cache.sqlite3")
        self.addCleanup(cache.close)
        source = catalog()
        result = translate.translate_catalog(
            source,
            ["es", "pt_BR", "fr", "it"],
            cache,
            lambda locale: FakeTranslator(locale),
            progress=lambda _: None,
        )

        self.assertNotIn("description_translations", source["mods"][0])
        translated = result["mods"][0]["description_translations"]
        self.assertEqual(["es", "pt_BR", "fr", "it"], list(translated))
        for text in translated.values():
            self.assertIn("`config.txt`", text)
            self.assertIn("https://example.com", text)
            self.assertIn("Lua", text)
        self.assertEqual(
            translate.canonical_mods_id(result["mods"]), result["catalog_id"]
        )

    def test_cache_avoids_retranslating_unchanged_descriptions(self):
        cache = translate.TranslationCache(self.root / "cache.sqlite3")
        calls = []

        class CountingTranslator(FakeTranslator):
            def translate(self, text):
                calls.append(text)
                return super().translate(text)

        for _ in range(2):
            translate.translate_catalog(
                catalog(),
                ["es"],
                cache,
                lambda locale: CountingTranslator(locale),
                progress=lambda _: None,
            )
        cache.close()
        self.assertEqual(2, len(calls))  # two non-empty lines, only first run

    def test_validator_accepts_output_and_rejects_source_mutation(self):
        source = catalog()
        cache = translate.TranslationCache(self.root / "cache.sqlite3")
        result = translate.translate_catalog(
            source,
            ["es", "pt_BR", "fr", "it"],
            cache,
            lambda locale: FakeTranslator(locale),
            progress=lambda _: None,
        )
        cache.close()
        source_path = self.root / "source.json"
        output_path = self.root / "translated.json"
        source_path.write_text(json.dumps(source), encoding="utf-8")
        output_path.write_text(json.dumps(result), encoding="utf-8")

        stats = validate.validate(
            output_path, source_path, ["es", "pt_BR", "fr", "it"]
        )
        self.assertEqual(1, stats["mods"])
        result["mods"][0]["name"] = "Altered"
        result["catalog_id"] = translate.canonical_mods_id(result["mods"])
        output_path.write_text(json.dumps(result), encoding="utf-8")
        with self.assertRaises(validate.ValidationError):
            validate.validate(
                output_path, source_path, ["es", "pt_BR", "fr", "it"]
            )


if __name__ == "__main__":
    unittest.main()
