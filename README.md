# FENR VCU Emulator

A local macOS BLE peripheral for testing FENR on a physical iPhone against a synthetic motorcycle. This models the known VCU protocol; it does not execute motorcycle firmware.

Requirements: macOS 14 or later, Xcode with Swift 6, XcodeGen 2.42 or later. Development baseline: Xcode 26.6. No cloud service or sibling checkout is required.

## Development

- `scripts/check.sh`: run package tests, generate the Xcode project, build and test the Mac app.
- `scripts/run.sh`: build with ad hoc signing and open the Mac app.
- `scripts/generate.sh`: regenerate the disposable Xcode project.

See [progress](docs/progress.md), [compatibility](docs/compatibility.md), and [plan](PLAN.md).

Bluetooth pairing is managed by macOS. Its PIN and bonding behavior may differ from the motorcycle. Physical motorcycle testing remains necessary.
