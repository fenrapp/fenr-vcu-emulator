#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Launch Services reuses an existing process even after its bundle is rebuilt.
# Refuse that path so this command always starts the executable it just built.
python3 - <<'CHECK_RUNNING'
import subprocess
from pathlib import PurePosixPath
processes = subprocess.check_output(["ps", "-axo", "comm="], text=True)
if any(PurePosixPath(line.strip()).name == "FENRVCUEmulator" for line in processes.splitlines()):
    raise SystemExit("Quit FENR VCU Emulator first, then run scripts/run.sh again to launch the current build.")
CHECK_RUNNING
scripts/generate.sh
xcodebuild -quiet -project FENRVCUEmulator.xcodeproj -scheme FENRVCUEmulator \
  -destination 'platform=macOS' -derivedDataPath DerivedData build
open DerivedData/Build/Products/Debug/FENRVCUEmulator.app
