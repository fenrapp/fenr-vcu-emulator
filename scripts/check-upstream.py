#!/usr/bin/env python3
"""Verify vendored bytes against the source manifest without another checkout."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
module = root / 'Modules/ProtocolCore'
manifest = json.loads((module / 'UpstreamManifest.json').read_text())
entries = manifest['files']
assert entries, 'No upstream sources in manifest'
listed = set()
for entry in entries:
    relative = Path(entry['vendored'])
    assert relative.parts[:2] == ('Sources', 'Upstream') and '..' not in relative.parts, 'Invalid manifest path'
    assert relative.as_posix() not in listed, 'Duplicate manifest entry'
    listed.add(relative.as_posix())
    path = module / relative
    assert hashlib.sha256(path.read_bytes()).hexdigest() == entry['sha256'], f'Upstream source changed: {relative}'
actual = {p.relative_to(module).as_posix() for p in (module / 'Sources/Upstream').rglob('*.swift')}
assert listed == actual, 'Upstream manifest does not match the vendored file set'
print(f'Verified {len(entries)} upstream source files against the committed manifest.')
