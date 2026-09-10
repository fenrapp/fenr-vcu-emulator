#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift test
scripts/generate.sh
xcodebuild -quiet -project FENRVCUEmulator.xcodeproj -scheme FENRVCUEmulator \
  -destination 'platform=macOS' -derivedDataPath DerivedData test
