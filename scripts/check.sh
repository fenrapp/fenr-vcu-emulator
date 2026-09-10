#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/build-paths.sh
python3 scripts/check-upstream.py
python3 scripts/check-localization.py
python3 scripts/check-architecture.py
swift test --scratch-path "$FENR_SWIFT_SCRATCH"
scripts/generate.sh
xcodebuild -quiet -project FENRVCUEmulator.xcodeproj -scheme FENRVCUEmulator \
  -destination "$FENR_DESTINATION" -derivedDataPath "$FENR_DERIVED_DATA" test
