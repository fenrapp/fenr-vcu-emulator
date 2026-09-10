# Physical validation checklist

## Current evidence

- Phase 0: clean clone built and tests passed; native macOS window inspected.
- Phase 1: engine tests and app build pass. The server was started on the Mac; Bluetooth authorization is pending. No iPhone connection is claimed.
- Pairing, CCCD discovery, negotiated payload sizes, reconnect and iPhone display: pending.

## Procedure

1. Run `scripts/run.sh`. Allow macOS Bluetooth access for FENR VCU Emulator.
2. Leave link encryption enabled and click Start. Expect Advertising.
3. Open FENR on a physical iPhone and add synthetic bike `FENRTEST000000001`, with pairing date `19700101`. Do not replace a real bike's identity with the synthetic identity.
4. Follow the OS pairing prompt. The displayed derived motorcycle PIN is synthetic; macOS may choose a different bonding flow. Record the actual flow rather than assuming the derived PIN applies.
5. Expect V2 authenticated. Activity should show a 32-byte security read, a 34-byte security write and telemetry subscriptions. Security payload bytes and central identifiers are never logged.
6. Change battery and speed in the Mac window. Verify the iPhone values. Charging should zero speed; increasing speed should end charging.
7. Disconnect from FENR, then reconnect. Expect a new authentication exchange and no updates from the previous session.
8. Stop and restart the emulator. Confirm GATT publication succeeds again.
9. If encrypted bonding prevents progress, stop the server, uncheck link encryption and repeat. Record this as application-only V2 testing; do not claim motorcycle bonding was tested.
10. Record the FENR source/build revision and Mac/iPhone OS versions. Check the maximum subscription bytes reported in Activity. The advanced configuration acceptance gate requires an actual 68-byte write and a 64-byte reply when those handlers exist.

Stopping advertising does not force a radio disconnect. This app removes services and invalidates application state when Stop is pressed; physical disconnect reasons remain controlled by the OS.

## Scope at the feasibility stage

Supported: Bike security/status, Live speed/map/totals, VCU versions, Battery SOC. Configuration requests explicitly return unsupported until their handlers are implemented. The current minimum telemetry model leaves unmodeled fields unavailable. No claim of complete vehicle fidelity is made.

## Results to record

For each run, record date, source revisions, OS versions, security profile, discovery, V2 result, battery/speed observation, reconnect, payload-size results and any blocker. Do not record device identifiers or raw security bytes.
