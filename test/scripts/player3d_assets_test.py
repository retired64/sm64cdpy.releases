"""APK packaging regressions require no Flutter, ROM or GPU."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('verify_player3d_assets', ROOT / 'scripts/verify_player3d_assets.py')
engine = importlib.util.module_from_spec(spec)
spec.loader.exec_module(engine)


class PlayerAssetsTest(unittest.TestCase):
    def make_apk(self, target, missing=None, stale=None):
        with zipfile.ZipFile(target, 'w') as archive:
            for asset in engine.required_assets():
                if asset == missing:
                    continue
                data = b'stale' if asset == stale else (ROOT / asset).read_bytes()
                archive.writestr('assets/flutter_assets/' + asset, data)

    def test_requires_nested_three_modules(self):
        assets = engine.required_assets()
        self.assertIn('assets/player3d/vendor/three.module.js', assets)
        self.assertIn('assets/player3d/vendor/three.core.js', assets)
        self.assertEqual(len(assets), 8)

    def test_packaged_graph_accepts_complete_sources(self):
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / 'complete.apk'
            self.make_apk(apk)
            engine.verify(apk)

    def test_rejects_missing_vendor_and_stale_module(self):
        with tempfile.TemporaryDirectory() as directory:
            apk = Path(directory) / 'broken.apk'
            self.make_apk(apk, missing='assets/player3d/vendor/three.core.js')
            with self.assertRaisesRegex(ValueError, 'missing Player assets.*three.core.js'):
                engine.verify(apk)
            self.make_apk(apk, stale='assets/player3d/app.js')
            with self.assertRaisesRegex(ValueError, 'stale Player asset'):
                engine.verify(apk)
