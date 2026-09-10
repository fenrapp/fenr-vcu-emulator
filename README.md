# FENR VCU Emulator

A native macOS workspace for testing FENR on a physical iPhone with a synthetic motorcycle. Version 0.2.0 includes scenario controls, editable configuration, reproducible failures, named presets and a shareable activity log. It models the known protocol; it does not execute motorcycle firmware.

## Run

Requires macOS 14+, Xcode 26+ with the macOS 26 SDK for Liquid Glass compilation, Swift 6, Python 3 and XcodeGen 2.42+. The verified toolchain is Xcode 26.6 on Apple Silicon. There are no remote services or dependencies on another local checkout.

```sh
scripts/run.sh
```

Quit an existing emulator first: the script refuses to reuse an old process after a rebuild. Allow Bluetooth, select **Start**, and wait for **Advertising**. In FENR, use synthetic motorcycle `FENRTEST000000001` and pairing date `19700101`. Session details contains the synthetic PIN and link-encryption option. macOS controls the actual pairing dialog.

The app starts stopped in **Parked**, with defaults and no fault. Loading saved state always requires an explicit action. See the [user guide](docs/usage.md).

## Development

```sh
scripts/check.sh       # Protocol, runtime, feature and app tests; architecture/localization checks
scripts/generate.sh    # Regenerate the disposable Xcode project
scripts/clean.sh       # Remove only this application's compiler caches
```

Xcode products live in `~/Library/Caches/FENRVCUEmulator/DerivedData`; SwiftPM uses `~/Library/Caches/FENRVCUEmulator/SwiftPM`. Presets live separately in `~/Library/Application Support/FENRVCUEmulator/presets.json`. Cleaning compiler caches does not remove presets. Manual in-checkout builds remain ignored by Git.

Read [architecture and contribution](docs/architecture.md), [compatibility](docs/compatibility.md), [testing](docs/testing.md), [physical validation](docs/physical-validation.md), [provenance](docs/upstream.md) and the [changelog](CHANGELOG.md).

This is a local repository with no remote publication. Physical acceptance is recorded separately from automatic tests. Emulation does not establish motorcycle write safety or physical motorcycle compatibility.
