# Validation

## Automatic checks

Run `scripts/check.sh` from the repository root. It verifies the vendored-source manifest, feature catalogs and architectural imports; runs Swift package tests; generates the Xcode project; and builds/tests the app with ad hoc signing and external caches.

Coverage includes independent wire fixtures and scales, V2 and replay rejection, offsets and bounded queues, signed configuration records and full curve readback, scenario resets/signals/interrupted charging, stale response cancellation, observer independence, ticker restart/teardown, atomic block conflicts, malformed presets/storage failures, mapper precision, filtering and injected clipboard export. Runtime tests retain test doubles in their own directory.

For an isolated checkout, clone this local repository to a temporary directory and run the same script. No sibling checkout is required. Verify `git status --porcelain` is empty and that `.build/` and `DerivedData/` are absent afterwards. Cache paths are shared by this application, so run builds serially. The generated Xcode project is disposable and ignored.

## Visual checks

Inspect Simulation, Configuration, Failures and Activity at 1100 x 760 and at the 800 x 600 minimum. Check numeric keyboard entry, scrolling, curve editing, disabled actions, preset loading and clipboard contents. Check system light/dark appearance and reduce-transparency fallback. Confirm the app icon remains legible at small sizes.

Do not mistake a rebuilt bundle for a relaunched executable: quit the old app before scripts/run.sh. A new ad hoc build can require a fresh macOS Bluetooth permission decision. Resolve that before diagnosing protocol timeouts.

## Physical checks

Use physical-validation.md and record the exact emulator/FENR commits and OS versions. Automatic byte/model tests do not prove iPhone interoperability. Keep captures and identifiers outside Git. No acceptance milestone is created until its complete checklist passes.
