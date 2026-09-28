import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "release_manifest", ROOT / "scripts" / "release_manifest.py"
)
release_manifest = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(release_manifest)


class ReleaseManifestTest(unittest.TestCase):
    def test_current_manifest_matches_pubspec_and_renders_content(self):
        manifest = release_manifest.load_manifest(
            ROOT / "release-manifests" / "v1.8.1.json"
        )
        release_manifest.validate_manifest(manifest)
        release_manifest.validate_pubspec(manifest, ROOT / "pubspec.yaml")

        notes = release_manifest.render_markdown(manifest, "en", include_force=True)
        self.assertIn("SM64CDPY v1.8.1", notes)
        self.assertIn("Catalog reliability", notes)
        self.assertNotIn("[FORCE]", notes)

    def test_empty_notes_are_rejected(self):
        manifest = release_manifest.load_manifest(
            ROOT / "release-manifests" / "v1.8.1.json"
        )
        manifest["locales"]["es"]["sections"] = []
        with self.assertRaises(release_manifest.ManifestError):
            release_manifest.validate_manifest(manifest)

    def test_pubspec_mismatch_is_rejected(self):
        manifest = release_manifest.load_manifest(
            ROOT / "release-manifests" / "v1.8.1.json"
        )
        with tempfile.TemporaryDirectory() as directory:
            pubspec = Path(directory) / "pubspec.yaml"
            pubspec.write_text("version: 9.9.9+99\n", encoding="utf-8")
            with self.assertRaises(release_manifest.ManifestError):
                release_manifest.validate_pubspec(manifest, pubspec)

    def test_all_committed_manifests_validate(self):
        for path in sorted((ROOT / "release-manifests").glob("v*.json")):
            with self.subTest(path=path.name):
                manifest = json.loads(path.read_text(encoding="utf-8"))
                release_manifest.validate_manifest(manifest)


if __name__ == "__main__":
    unittest.main()
