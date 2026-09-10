# Testing and acceptance

## Automatic checks

Run `scripts/check.sh`. It executes the vendored-source hash check, localization key check, `swift test`, XcodeGen, and `xcodebuild test` for scheme FENRVCUEmulator with destination platform=macOS and DerivedData and SwiftPM artifacts in ~/Library/Caches/FENRVCUEmulator, outside the checkout.

The tested development toolchain is Xcode 26.6. Xcode project generation and app signing require no personal signing team. The generated project is disposable. No repository-relative dependency points outside the clone.

For a clean-clone check, clone the current local branch into a temporary directory and run that clone's scripts/check.sh. Build caches, result bundles and captured output belong in ignored artifacts or temporary storage.

## Cases

- Independent V2 digest fixture, invalid identity, invalid response, nonce expiry, second client exclusion and replay rejection.
- Session teardown invalidates queued notifications; security unsubscribe before telemetry subscribe remains supported, with a 30-second handoff deadline to release abandoned clients.
- Battery, speed, status and version bytes; deterministic ride distance and charge-target progression.
- Configuration no-op/read/write/readback with complete sibling preservation and invalid request atomicity.
- Signed traction values, mode 0x0F, lock type/timeout, five advanced curves and distinct write/read layouts.
- Configuration survives reconnect; cached replies do not. Reset scenario restores configuration.
- Bounded/coalesced notification queues, response deadlines and stale delayed responses across reconnect, scenario reset and fault-profile changes.
- Rejected authentication, missing responses, read failure then explicit traction commit, unsupported firmware/records, unapplied writes, frozen and malformed telemetry.
- App controls without Bluetooth activation; stop/restart/deinit cancels periodic publication.

## Manual checks

Use docs/physical-validation.md. Unit tests cannot establish real pairing UX, radio link exclusivity, negotiated transport limits, disconnect reasons or iPhone interoperability. Native UI needs an inspection at the intended window size. Testing on a current Mac does not establish macOS 14 runtime coverage.
