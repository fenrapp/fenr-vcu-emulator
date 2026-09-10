# Implementation progress

Repository: local Git, no remote. All phases 0-4 are integrated in main with their small conventional commits preserved. The user requested all implementation before one final physical validation pass. Phase branches remain available as historical checkpoints. Acceptance tags remain separate from software integration; only milestone/phase-0 currently exists.

| Phase | Software | Automatic validation | Physical acceptance |
| --- | --- | --- | --- |
| 0 | Native app, modules, scripts, autonomous build | Passed, including a clean clone | Native bootstrap window launched and inspected; milestone/phase-0 exists |
| 1 | GATT peripheral, V2, battery/speed/status, session recovery | Passed | Bluetooth authorization and physical iPhone connection pending |
| 2 | Deterministic scenarios, controls, temperature/map, activity | Passed | Earlier dashboard and Charging selection inspected on Mac; iPhone behavior pending |
| 3 | Stateful charging/maps/traction/lock/advanced curves | Passed | Earlier configuration inspector inspected on Mac; iPhone writes/readback pending |
| 4 | Fault profiles, response scheduling, inspection UI | Passed | Failure selector inspected; fault behavior on iPhone pending |

## Verification environment

Development toolchain: Xcode 26.6, Swift 6 language mode, Apple Silicon Mac. Protocol source baseline: 429e5a05f752ec8ac77cd88cb54e3fac65b6fc34. No iOS working-tree changes were copied.

Validated implementation revision: `48e2c7f6d3b3c468d396d64fe2cfe804acb2f68a`. Subsequent integration documentation does not change the executable sources.

The final automatic run passes 26 package tests and 3 app tests, vendored-source hashes, localization keys, project generation and app compilation. Package tests cover wire fixtures, authentication, signed traction, curve layout, stateful configuration, reconnects, fault behavior and notification queue bounds. App tests cover presentation consistency and owned ticker cancellation/restart/deinit. The complete source also passes scripts/check.sh from a fresh local clone with no sibling dependency.

Final recovery fixes release an abandoned security-to-telemetry handoff after 30 seconds and invalidate queued replies when resetting a scenario or changing a fault profile. Active authenticated telemetry subscriptions remain intact during a scenario reset. See scripts/check.sh for the exact checks.

## Remaining acceptance work

1. Confirm macOS Bluetooth permission and actual advertising on this Mac. The attempted start remained at Starting Bluetooth; no advertising success has been observed.
2. Complete the physical iPhone checklist, including bonding profile, V2, CCCD, 68-byte writes and 64-byte replies.
3. Recheck the final window layout at small sizes. An earlier native inspection found clipping; the layout now uses an outer scroll view and an in-content section picker. The computer-use service then failed with a closed native pipe, so the final layout correction has passed compilation but has not been re-inspected live.
4. Validate the displayed configuration and failure behavior against the iPhone. Record results and create the corresponding acceptance tags only when their checks pass.

Software integration is complete; no iPhone is required to build, run or inspect all implemented phases. Actual BLE interoperability remains unverified. Any macOS limitation discovered in the final physical pass must be resolved before claiming the corresponding acceptance milestone.
