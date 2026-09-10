#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 scripts/check-upstream.py
python3 scripts/check-localization.py
swift test
scripts/generate.sh
xcodebuild -quiet -project FENRVCUEmulator.xcodeproj -scheme FENRVCUEmulator \
  -destination 'platform=macOS' -derivedDataPath DerivedData test
