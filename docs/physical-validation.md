# Physical validation

## Evidence and limits

Automatic protocol, lifecycle, storage and presentation tests run locally and in CI. Native UI inspection has covered light/dark appearance, normal/compact windows, numeric editing, configuration Apply, curves, fault controls, preset save/load/rename and clipboard export on macOS 26.6.2.

On 2026-09-10, the earlier emulator was confirmed to work with physical iPhone discovery, V2 onboarding, recovery from Partial telemetry to Parked and FENR close/reopen with dashboard data. The client used the authenticated-target identity correction in FENR iOS revision `3c5582dd8c095c56f06c1482ef2dba85d4b6bf81`.

Those observations do not establish physical acceptance of every redesigned control, configuration record or failure profile. The checklist below remains the acceptance procedure. Runtime testing on macOS 14, a complete VoiceOver pass and complete iPhone configuration/failure coverage are still pending. No motorcycle write-validation claim is made.

## Connection and telemetry

1. Build and open a fresh emulator. Resolve the macOS Bluetooth permission prompt before diagnosing a protocol timeout. Rebuilding an ad hoc executable can require a new permission decision.
2. Start in Parked with link encryption enabled. Expect Advertising, then connect FENR using the synthetic identity in README.md.
3. Follow the OS pairing flow. Expect V2 authenticated, a 32-byte security read, a 34-byte security write and telemetry subscriptions. Do not record authentication payload bytes.
4. Verify battery, speed, active map and temperatures. Exercise ignition, gear, indicators, hazards, high beam and brake where the client displays them. Brake changes its signal; Stop movement sets speed to zero.
5. Select Charging. Change requested/delivered current and voltage, then check the calculated values in FENR. Interrupt charging and verify that delivered current stops while charger connection remains.
6. Close and reopen FENR; verify fresh authentication and live telemetry. Stop and restart the Mac server; verify that services publish again.
7. Select Partial telemetry, observe the intentional startup wait and use Return to Parked to recover.
8. If necessary, repeat with application-only V2 after stopping the server and disabling link encryption. Record the security profile separately from encrypted bonding.

## Configuration

Use normal operation and a compatible FENR build. Observe preparation/no-op checks, command results and fresh reads in Activity.

- Change charging power and target; check readback and charger telemetry.
- Change each base map while retaining its sibling fields.
- Confirm both signed traction values and bike-lock settings exactly.
- Read/write all five advanced curve pairs, preserving all 15 power and 15 regeneration samples. Verify a 68-byte write and 64-byte response without invented fragmentation.
- Open a Mac draft, modify that block from FENR and confirm Reload is required before Apply. Changes in unrelated blocks must survive.
- Navigate and manage local presets in FENR; verify no configuration mutations occur merely from navigation or preset management.
- Reconnect and verify current configuration remains. Reset scenario must preserve it; Reset all values must restore defaults.

## Failure and recovery

Return to No fault between independent cases. Stop before changing a profile marked as requiring it.

| Profile | Expected check |
| --- | --- |
| Authentication rejection | No protected telemetry or configuration access |
| Delayed responses | Selected delay is applied; client timeout and recovery are visible |
| Missing responses | Application replies are suppressed; the radio link remains present |
| Frozen telemetry | Selected datasets retain previous values while simulation continues |
| Malformed speed | Client rejects the one-byte payload without crashing |
| Unsupported firmware/capabilities | Configuration cannot report unsupported success |
| Accepted but unapplied writes | Fresh reads reveal the unchanged values |
| Failed traction reads | No background initialization; an explicit traction write can restore fresh confirmation |

Reset or change the fault while replies are delayed and verify old replies cannot update the new session. Stopping advertisements is not a disconnection primitive. For actual link loss, manually interrupt Bluetooth and record what the client observes.

## Recording a run

Record emulator/FENR commits, OS versions, scenario, security/fault profile, reproduction steps, expected/actual values and negotiated payload sizes. Copy a scoped Activity export and use synthetic screenshots. Exclude private identifiers, credentials and raw security payloads. Only create acceptance tags after the corresponding complete checklist passes.
