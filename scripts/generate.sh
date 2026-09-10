#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
xcodegen generate
