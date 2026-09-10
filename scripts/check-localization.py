#!/usr/bin/env python3
"""Check static UI resources without rewriting the catalog."""
import json
import re
from pathlib import Path
root = Path(__file__).resolve().parents[1]
keys = json.loads((root / 'App/Resources/Localizable.xcstrings').read_text())['strings']
missing = []
for path in (root / 'App/Sources').rglob('*.swift'):
    text = path.read_text()
    for pattern in [r'(?:Text|Button|Toggle|GroupBox|Window|Picker)\("([^"\\]*)"',
                    r'String\(localized: "([^"\\]*)"', r'TelemetryControl\(title: "([^"\\]*)"']:
        for key in re.findall(pattern, text):
            if key not in keys:
                missing.append(f'{path.relative_to(root)}: {key}')
if missing:
    raise SystemExit('\n'.join(missing))
print('Static localization keys verified. Review interpolated keys and diagnostic strings separately.')
