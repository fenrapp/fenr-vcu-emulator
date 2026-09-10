#!/usr/bin/env python3
"""Check the presentation boundary without importing platform implementation modules."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
errors = []
for feature in (root / 'Features').iterdir():
    for folder in ['UI', 'Models']:
        for path in (feature / 'Sources' / folder).rglob('*.swift'):
            for name in re.findall(r'^import (\w+)', path.read_text(), re.M):
                if name not in {'SwiftUI', 'Foundation', 'Charts', 'DesignSystem'}:
                    errors.append(f'{path.relative_to(root)} imports {name}')
    for path in (feature / 'Sources').rglob('*.swift'):
        if re.search(r'\b(?:EmulatorEngine|PeripheralServer|LiveEmulatorRepository|LocalPresetStore)\s*\(', path.read_text()):
            errors.append(f'{path.relative_to(root)} constructs infrastructure')
for path in (root / 'Modules/DesignSystem/Sources').rglob('*.swift'):
    for name in re.findall(r'^import (\w+)', path.read_text(), re.M):
        if name not in {'SwiftUI', 'Foundation'}:
            errors.append(f'{path.relative_to(root)} imports {name}')
if errors:
    raise SystemExit('\n'.join(errors))
print('Feature presentation and design-system boundaries verified.')
