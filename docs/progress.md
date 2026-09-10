# Implementation progress

Repository: local Git, no remote. All phases 0-4 are integrated in main with their small conventional commits preserved. The user requested all implementation before one final physical validation pass. Phase branches remain available as historical checkpoints. Acceptance tags remain separate from software integration; only milestone/phase-0 currently exists.

| Phase | Software | Automatic validation | Physical acceptance |
| --- | --- | --- | --- |
| 0 | Native app, modules, scripts, autonomous build | Passed, including a clean clone | Native bootstrap window launched and inspected; milestone/phase-0 exists |
| 1 | GATT peripheral, V2, battery/speed/status, session recovery | Passed | LightBlue discovery, V2 and FENR onboarding/dashboard confirmed with local iOS identity fix; full acceptance pending |
| 2 | Deterministic scenarios, controls, temperature/map, activity | Passed | Partial-telemetry startup wait and recovery to Parked confirmed on iPhone; remaining scenarios pending |
| 3 | Stateful charging/maps/traction/lock/advanced curves | Passed | Earlier configuration inspector inspected on Mac; iPhone writes/readback pending |
| 4 | Fault profiles, response scheduling, inspection UI | Passed | Failure selector inspected; fault behavior on iPhone pending |

## Verification environment

Development toolchain: Xcode 26.6, Swift 6 language mode, Apple Silicon Mac. Protocol source baseline: 429e5a05f752ec8ac77cd88cb54e3fac65b6fc34. No iOS working-tree changes were copied.

Validated implementation revision: `48e2c7f6d3b3c468d396d64fe2cfe804acb2f68a`. Subsequent integration documentation does not change the executable sources.

The final automatic run passes 26 package tests and 3 app tests, vendored-source hashes, localization keys, project generation and app compilation. Package tests cover wire fixtures, authentication, signed traction, curve layout, stateful configuration, reconnects, fault behavior and notification queue bounds. App tests cover presentation consistency and owned ticker cancellation/restart/deinit. The complete source also passes scripts/check.sh from a fresh local clone with no sibling dependency.

Final recovery fixes release an abandoned security-to-telemetry handoff after 30 seconds and invalidate queued replies when resetting a scenario or changing a fault profile. Active authenticated telemetry subscriptions remain intact during a scenario reset. See scripts/check.sh for the exact checks.

## Remaining acceptance work

1. Discovery was confirmed by the user in iPhone LightBlue on 2026-09-10 after rebuilding and launching the current executable. Bluetooth permission and name advertising now have physical evidence; FENR V2 and dashboard startup were subsequently confirmed with the local client correction described below.
2. Complete the physical iPhone checklist, including bonding profile, V2, CCCD, 68-byte writes and 64-byte replies.
3. Recheck the final window layout at small sizes. An earlier native inspection found clipping; the layout now uses an outer scroll view and an in-content section picker. The computer-use service then failed with a closed native pipe, so the final layout correction has passed compilation but has not been re-inspected live.
4. Validate the displayed configuration and failure behavior against the iPhone. Record results and create the corresponding acceptance tags only when their checks pass.

Software integration is complete; no iPhone is required to build, run or inspect all implemented phases. Full BLE acceptance remains incomplete. Any macOS limitation discovered in the final physical pass must be resolved before claiming the corresponding acceptance milestone.

## Advertising investigation (2026-09-10)

The earlier running process requested a full synthetic name plus the 128-bit bike-service UUID. The committed implementation already requested the name alone, but that change was not present in the running binary. After a fresh build and launch, the macOS daemon recorded the name-only request and the user confirmed that FENRTEST000000001 appeared in LightBlue on the iPhone. No raw system log or device identifier is versioned.

This establishes discoverability for the rebuilt implementation on this Mac; it does not establish V2 or configuration interoperability. The run script now refuses to reuse an already-running emulator, preventing Launch Services from silently keeping an earlier executable after a rebuild.

## Authenticated startup correction (2026-09-10)

The physical iPhone completed the security exchange and subscribed to telemetry, but stayed on Securing the connection. The emulator incorrectly exposed SOC as 6003 (battery parameters), while the pinned FENR client requires SOC on 6004 for complete telemetry. The UUID is corrected and an independent full-UUID startup regression test covers all six required datasets.

Correction commit: `79ae59e`. Automatic validation passes 27 package tests and 3 app tests. The corrected app has been rebuilt for the physical retry. Dashboard arrival was subsequently confirmed with the additional client identity correction described below; subscription evidence alone was insufficient to establish complete startup acceptance.

## iPhone onboarding and partial telemetry (2026-09-10)

FENR main at `0010f600` discarded onboarding completion when the Mac GAP name differed from the synthetic VIN. A local client candidate, `3c5582dd` on `bugfix/authenticated-connection-identity`, uses the validated target VIN for the ready event only after V2 authentication. The main iOS checkout remains unchanged; the candidate was built independently in a temporary checkout. Its 158 BikeSDK tests pass, and the signed physical app passes the runtime dependency validator (46 Mach-O images). Temporary startup instrumentation is excluded from the committed candidate.

The user confirmed successful onboarding with this candidate. Closing and reopening FENR while the emulator used Partial telemetry left it on Waiting for live telemetry. The physical diagnostic run showed valid battery SOC values but no status, speed, map, totals or brake samples. Returning to Parked and resetting the scenario restored all six datasets; the user confirmed that the dashboard appeared. This is the partial scenario's intentional behavior, not a failed V2 exchange.

After installing the clean candidate binary without temporary startup instrumentation, the user confirmed that battery and speed appeared on both the initial opening and a close/reopen cycle with Parked selected.

These observations establish startup, app relaunch and recovery for this Mac/iPhone combination, not complete configuration, failure-profile or motorcycle validation. No additional milestone tag is justified yet. No private device identifiers or raw diagnostic captures are included here.
