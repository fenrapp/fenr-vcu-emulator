#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/build-paths.sh
python3 - "$FENR_CACHE_ROOT" <<'CLEAN'
import shutil, sys
from pathlib import Path
root = Path(sys.argv[1])
expected = Path.home() / 'Library/Caches/FENRVCUEmulator'
if root != expected or root.is_symlink():
    raise SystemExit('Refusing to clean an unexpected cache path.')
for name in ('DerivedData', 'SwiftPM'):
    path = root / name
    if path.is_symlink():
        raise SystemExit('Refusing to follow a cache symlink.')
    if path.exists():
        shutil.rmtree(path)
print('Emulator build caches removed. Presets are unchanged.')
CLEAN
