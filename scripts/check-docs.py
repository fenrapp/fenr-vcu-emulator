#!/usr/bin/env python3
"""Check relative Markdown targets and reviewed screenshot files without networking."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
errors = []
for path in [*root.glob('*.md'), *(root / 'docs').rglob('*.md')]:
    for target in re.findall(r'\]\(([^\s)]+)(?:\s+"[^"]*")?\)', path.read_text()):
        if '://' in target or target.startswith(('mailto:', '#')):
            continue
        target = target.split('#', 1)[0]
        if not (path.parent / target).exists():
            errors.append(f'{path.relative_to(root)}: missing {target}')
image = root / 'docs/images/simulation.jpg'
if not image.is_file() or image.read_bytes()[:3] != b'\xff\xd8\xff':
    errors.append('README screenshot is missing or not a JPEG')
if errors:
    raise SystemExit('\n'.join(errors))
print('Documentation targets and README screenshot verified.')
