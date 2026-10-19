#!/usr/bin/env python3
"""Prepare Flutter's exact NDK before Gradle; retry incomplete SDK installs."""
from __future__ import annotations

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def required_version(flutter_root: Path) -> str:
    source = flutter_root / 'packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt'
    match = re.search(r'val\s+ndkVersion\s*:\s*String\s*=\s*"(\d+\.\d+\.\d+)"', source.read_text())
    if not match:
        raise RuntimeError('Cannot determine the NDK version required by Flutter')
    return match.group(1)


def ready(directory: Path, version: str) -> bool:
    try:
        properties = (directory / 'source.properties').read_text()
        return (
            re.search(r'^Pkg\.Revision\s*=\s*' + re.escape(version) + r'\s*$', properties, re.M) is not None
            and (directory / 'build/cmake/android.toolchain.cmake').is_file()
            and (directory / 'toolchains/llvm/prebuilt/linux-x86_64/bin/clang').is_file()
        )
    except OSError:
        return False


def prepare(sdk_root: Path, flutter_root: Path, sdkmanager: str,
            attempts: int = 3, delay: float = 5) -> str:
    version = required_version(flutter_root)
    ndk_parent = sdk_root.resolve() / 'ndk'
    directory = ndk_parent / version
    for attempt in range(1, attempts + 1):
        if ready(directory, version):
            print(f'NDK {version} verified', flush=True)
            return version
        # Never remove another NDK version, a valid installation or a symlink.
        if directory.is_symlink() or directory.resolve() != ndk_parent.resolve() / version:
            raise RuntimeError('Refusing to clean an unexpected NDK path')
        if directory.exists():
            shutil.rmtree(directory)
        print(f'Installing NDK {version}: attempt {attempt}/{attempts}', flush=True)
        result = subprocess.run([sdkmanager, f'--sdk_root={sdk_root.resolve()}',
                                 '--install', f'ndk;{version}'], check=False)
        if result.returncode == 0 and ready(directory, version):
            print(f'NDK {version} verified', flush=True)
            return version
        if attempt < attempts:
            time.sleep(delay * attempt)
    raise RuntimeError(f'NDK {version} could not be prepared after {attempts} attempts')


def main() -> int:
    try:
        sdk = os.environ.get('ANDROID_SDK_ROOT') or os.environ.get('ANDROID_HOME')
        flutter = os.environ.get('FLUTTER_ROOT')
        if not sdk or not flutter:
            raise RuntimeError('ANDROID_SDK_ROOT/ANDROID_HOME and FLUTTER_ROOT must be set')
        manager = shutil.which('sdkmanager') or str(Path(sdk) / 'cmdline-tools/latest/bin/sdkmanager')
        if not Path(manager).is_file():
            raise RuntimeError('Android SDK command-line tools are unavailable')
        prepare(Path(sdk), Path(flutter), manager)
        return 0
    except (OSError, RuntimeError) as error:
        print(f'::error::{error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
