#!/usr/bin/env python3
"""Verify static display keys against each owning catalog; no source rewriting."""
import json
import re
from pathlib import Path
root = Path(__file__).resolve().parents[1]
missing = []
owners = [root / 'App'] + list((root / 'Features').iterdir())
for owner in owners:
    catalog = owner / 'Resources/Localizable.xcstrings'
    keys = json.loads(catalog.read_text())['strings']
    for path in (owner / 'Sources').rglob('*.swift'):
        source = path.read_text()
        patterns = [r'(?:Text|Button|Toggle|LabeledContent|Window|Picker|DisclosureGroup|navigationTitle)\("((?:[^"\\]|\\.)*)"',
                    r'String\(localized: "((?:[^"\\]|\\.)*)"',
                    r'(?:simulationText|configurationText|failureText|activityText)\("((?:[^"\\]|\\.)*)"']
        for pattern in patterns:
            for key in re.findall(pattern, source):
                key = re.sub(r'\\\([^)]*\)', '%lld', key)
                if key not in keys:
                    missing.append(f'{path.relative_to(root)}: {key}')
if missing:
    raise SystemExit('\n'.join(missing))
print('App and feature localization keys verified. Review dynamic display keys separately.')
