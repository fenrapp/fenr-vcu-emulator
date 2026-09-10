# Implementation progress

- Repository: local Git, main branch, no remote.
- Phase 0: passed package tests and xcodebuild app tests on Xcode 26.6, including a clean local clone. Native window launched and visually inspected on macOS. No sibling checkout dependency.
- Phase 1: implemented and automatically tested; native controls inspected. Bluetooth authorization and physical iPhone validation pending. No milestone tag.
- Phases 2-4: software implementation may proceed on stacked branches with automatic tests; physical acceptance and main integration remain gated on phase 1.

Milestone tags require all acceptance checks, including physical checks where specified. A passing build is not evidence of BLE connectivity.
