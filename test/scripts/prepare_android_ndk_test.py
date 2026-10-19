import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

MODULE = Path(__file__).resolve().parents[2] / 'scripts/prepare_android_ndk.py'
spec = importlib.util.spec_from_file_location('prepare_android_ndk', MODULE)
ndk = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ndk)


class PrepareNdkTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.sdk = self.root / 'sdk'
        self.flutter = self.root / 'flutter'
        source = self.flutter / 'packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt'
        source.parent.mkdir(parents=True)
        source.write_text('val ndkVersion: String = "28.2.13676358"')
        self.directory = self.sdk / 'ndk/28.2.13676358'

    def install(self):
        for name, data in [('source.properties', 'Pkg.Revision = 28.2.13676358\n'),
                           ('build/cmake/android.toolchain.cmake', ''),
                           ('toolchains/llvm/prebuilt/linux-x86_64/bin/clang', '')]:
            target = self.directory / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(data)

    def test_existing_complete_installation_avoids_network(self):
        self.install()
        with patch.object(ndk.subprocess, 'run') as run:
            ndk.prepare(self.sdk, self.flutter, 'sdkmanager', delay=0)
            run.assert_not_called()

    def test_bad_download_cleans_only_incomplete_target_and_retries(self):
        sibling = self.sdk / 'ndk/other/keep.txt'
        sibling.parent.mkdir(parents=True)
        sibling.write_text('keep')
        calls = []
        def run(command, **kwargs):
            calls.append(command)
            self.directory.mkdir(parents=True, exist_ok=True)
            if len(calls) == 1:
                (self.directory / 'broken').write_text('not a ZIP')
                return subprocess.CompletedProcess(command, 1)
            self.assertFalse((self.directory / 'broken').exists())
            self.install()
            return subprocess.CompletedProcess(command, 0)
        with patch.object(ndk.subprocess, 'run', side_effect=run):
            ndk.prepare(self.sdk, self.flutter, 'sdkmanager', delay=0)
        self.assertEqual(len(calls), 2)
        self.assertEqual(sibling.read_text(), 'keep')

    def test_download_failures_stop_after_three_attempts(self):
        with patch.object(ndk.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1)) as run:
            with self.assertRaises(RuntimeError):
                ndk.prepare(self.sdk, self.flutter, 'sdkmanager', delay=0)
            self.assertEqual(run.call_count, 3)

    def test_cleanup_rejects_symlink_outside_sdk(self):
        outside = self.root / 'outside'
        outside.mkdir()
        self.directory.parent.mkdir(parents=True)
        self.directory.symlink_to(outside, target_is_directory=True)
        with patch.object(ndk.subprocess, 'run') as run:
            with self.assertRaises(RuntimeError):
                ndk.prepare(self.sdk, self.flutter, 'sdkmanager', delay=0)
            run.assert_not_called()
        self.assertTrue(outside.exists())
