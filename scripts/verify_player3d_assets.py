#!/usr/bin/env python3
"""Gate APKs on the actual local Player module graph, without ROM/GPU inputs."""
from __future__ import annotations

import argparse
from pathlib import Path, PurePosixPath
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
FROM = re.compile(r'''(?:import|export)[^;]*?from\s*["']([^"']+)["']''')
SCRIPTS = re.compile(r'''<script\b[^>]*\bsrc=["']([^"']+)["']''')


def required_assets(root: Path = ROOT) -> set[str]:
    directory = root / 'assets/player3d'
    pending = list(SCRIPTS.findall((directory / 'index.html').read_text()))
    required = {'assets/player3d/index.html'}
    while pending:
        relative = pending.pop()
        # All current module paths are relative to their owner's local directory.
        name = PurePosixPath(relative)
        if name.is_absolute() or '..' in name.parts or ':' in relative:
            raise ValueError(f'Nonlocal Player module: {relative}')
        asset = 'assets/player3d/' + str(name)
        if asset in required:
            continue
        required.add(asset)
        source = (root / asset).read_text()
        for target in FROM.findall(source):
            if not target.startswith('./'):
                raise ValueError(f'Nonlocal Player import: {target}')
            pending.append(str(name.parent / target))
    return required


def verify(apk: Path, root: Path = ROOT) -> None:
    with zipfile.ZipFile(apk) as archive:
        required = sorted(required_assets(root))
        missing = [asset for asset in required if 'assets/flutter_assets/' + asset not in archive.namelist()]
        if missing:
            raise ValueError(f'{apk.name}: missing Player assets: {", ".join(missing)}')
        for asset in required:
            name = 'assets/flutter_assets/' + asset
            try:
                actual = archive.read(name)
            except KeyError as error:
                raise ValueError(f'{apk.name}: missing Player asset {asset}') from error
            if actual != (root / asset).read_bytes():
                raise ValueError(f'{apk.name}: stale Player asset {asset}')
    print(f'{apk.name}: Player HTML + all local modules verified')


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apks', type=Path, nargs='+')
    args = parser.parse_args()
    for apk in args.apks:
        verify(apk)


if __name__ == '__main__':
    main()
