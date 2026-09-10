#!/usr/bin/env python3
"""Verify the vendored source manifest without accessing the original repository."""
import hashlib
import re
from pathlib import Path
root = Path(__file__).resolve().parents[1]
manifest = (root / 'docs/upstream.md').read_text()
entries = re.findall(r'- `(Modules/StarkProtocol/Sources/[^`]+)`: `([0-9a-f]{64})`', manifest)
assert entries, 'No upstream sources in manifest'
for source, expected in entries:
    path = root / 'Sources/ProtocolCore/Upstream' / source.removeprefix('Modules/StarkProtocol/Sources/')
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    assert actual == expected, f'Upstream source changed: {path.relative_to(root)}'
listed = {source.removeprefix('Modules/StarkProtocol/Sources/') for source, _ in entries}
actual = {str(p.relative_to(root / 'Sources/ProtocolCore/Upstream')) for p in (root / 'Sources/ProtocolCore/Upstream').rglob('*.swift')}
assert listed == actual, 'Upstream manifest does not match the vendored file set'
print(f'Verified {len(entries)} upstream source files against the committed manifest.')
