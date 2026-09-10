# FENR VCU Emulator

A native macOS BLE peripheral for testing FENR on a physical iPhone against a synthetic motorcycle. It models the known VCU protocol; it does not execute motorcycle firmware.

**Status:** phases 0-4 have software implementations and automated tests. Only phase 0 has complete acceptance. Physical iPhone interoperability is still pending. The complete working implementation is on `feature/fault-scenarios`; `main` remains at the accepted bootstrap milestone. There is no remote.

## Run

Requirements: macOS 14 or later, Xcode 26.6 (tested toolchain, Swift 6 language mode), Python 3 and XcodeGen 2.42 or later. No cloud service or sibling checkout is required. Runtime compatibility on macOS 14 itself has not been physically tested.

From the repository directory:

```sh
scripts/run.sh
```

Allow Bluetooth access for FENR VCU Emulator, then click **Start**. The window should report **Advertising**. Discover synthetic bike `FENRTEST000000001` in FENR and use pairing date `19700101`. The derived motorcycle PIN is displayed in the Mac window; macOS controls the real bonding dialog and may use a different procedure. Never use a real motorcycle's identity for this emulator.

The **Dashboard** changes battery, speed, temperature and active map. Select Parked, Riding, Charging or Partial telemetry. Battery evolution is intentionally accelerated to one percentage point per simulated minute; it is not a physical battery model.

The **Configuration** panel inspects charge settings, maps, traction, lock and all advanced-curve samples. Make configuration changes from FENR on the iPhone and inspect the resulting values here. The **Failures** panel selects a reproducible fault before starting the peripheral.

Stop pauses simulation and invalidates the application session. Configuration survives reconnects in the same process. **Reset scenario** restores telemetry and configuration defaults; restarting the application also restores defaults. Nothing is persisted between runs.

## Verify

```sh
scripts/check.sh
```

This verifies vendored-source hashes and static localization keys, runs Swift package tests, generates the disposable Xcode project, and builds/tests the Mac app with ad hoc signing. `scripts/generate.sh` only regenerates the project. Build output and local evidence are ignored by Git.

Read [implementation progress](docs/progress.md), [physical validation](docs/physical-validation.md), [testing](docs/testing.md), [compatibility](docs/compatibility.md), and the [implementation plan](PLAN.md).

## Boundaries

Supported configuration records: base maps (0), advanced curves (1), charging (4), bike lock (5) and traction (8). Unknown commands fail explicitly. The basic BLE telemetry subset covers status, speed, map, totals, battery SOC, battery/inverter temperatures, charger and brake status. Uncharacterized measurements, full BMS diagnostics, ownership operations and firmware writes are not implemented.

Link encryption is enabled by default. Turning it off preserves V2 authentication but reduces bonding fidelity; stop and reconnect to change this profile. Missing-response fault mode advertises configuration as notification/write-only and suppresses its application responses. Delayed-response mode holds configuration replies for six seconds. These profiles test client behavior, not precise motorcycle radio faults.

Stopping advertisements alone is not a radio disconnect. The app removes its services and invalidates sessions on Stop; exact disconnect behavior belongs to macOS. Physical motorcycle testing remains necessary, especially for traction, lock and advanced-curve writes.
