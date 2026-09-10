#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
scripts/generate.sh
xcodebuild -quiet -project FENRVCUEmulator.xcodeproj -scheme FENRVCUEmulator \
  -destination 'platform=macOS' -derivedDataPath DerivedData build
open DerivedData/Build/Products/Debug/FENRVCUEmulator.app
