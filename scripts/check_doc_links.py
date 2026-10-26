#!/usr/bin/env python3
"""Check local Markdown link destinations; no network or anchor validation."""

from pathlib import Path
import re
from urllib.parse import unquote


ROOT = Path(__file__).resolve().parents[1]


def main():
    failures = []
    documents = sorted(ROOT.glob('*.md')) + sorted((ROOT / 'docs').rglob('*.md'))
    for directory in ('media', 'scripts', 'tools', 'db'):
        documents.extend(sorted((ROOT / directory).rglob('*.md')))
    for document in documents:
        content = re.sub(r'^```.*?^```[^\n]*',
                         lambda match: '\n' * match.group(0).count('\n'),
                         document.read_text(),
                         flags=re.MULTILINE | re.DOTALL)
        for match in re.finditer(r'\]\(([^)]+)\)', content):
            target = match.group(1).strip()
            if re.match(r'(?:[a-zA-Z][\w+.-]*:|#|/)', target):
                continue
            # Optional Markdown link titles are not part of the path.
            target = target.split(' "', 1)[0].strip('<>')
            path = unquote(target.split('#', 1)[0].split('?', 1)[0])
            if not (document.parent / path).exists():
                line = content.count('\n', 0, match.start()) + 1
                failures.append(f'{document.relative_to(ROOT)}:{line}: {target}')
    if failures:
        print('\n'.join(failures))
        return 1
    print(f'Local Markdown links OK ({len(documents)} documents).')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
