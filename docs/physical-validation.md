# Physical validation checklist

## Evidence status

Automatic tests pass. The native bootstrap and earlier dashboard/configuration/failure controls have been inspected. On 2026-09-10 the user confirmed the synthetic name in iPhone LightBlue after launching a fresh build; macOS logs confirmed the current name-only advertising request. V2 over the air, FENR rendering and physical configuration transactions are not yet verified. No motorcycle write-validation claim is made.

## Connection

1. Run `scripts/run.sh`. Allow macOS Bluetooth access for FENR VCU Emulator.
2. Leave link encryption enabled and click Start. Expect Advertising. If permission is still pending, resolve that before interpreting a timeout as a protocol failure.
3. Open FENR on a physical iPhone and add synthetic bike `FENRTEST000000001`, with pairing date `19700101`. Do not modify a real bike's identity.
4. Follow the OS pairing prompt. The displayed derived motorcycle PIN is synthetic; macOS may use a different bonding flow. Record the actual behavior.
5. Expect V2 authenticated. Activity should show a 32-byte security read, a 34-byte security write and telemetry subscriptions. Payload bytes and central identifiers are never logged.
6. Change battery and speed. Verify the iPhone values. Charging zeros speed; increasing speed ends charging. Verify map and temperature where FENR exposes them.
7. Disconnect from FENR, then reconnect. Expect fresh authentication and no updates from the prior session.
8. Stop and restart the emulator. Confirm services are published again.
9. If encrypted bonding prevents progress, stop, disable link encryption and repeat. Record this as application-only V2 testing, not motorcycle bonding validation.

## Configuration

Use normal operation and a current FENR build matching the documented protocol baseline. Observe FENR's preparation/no-op checks and fresh reads in Activity.

- Change charge power and target; verify configuration values and subsequent charger telemetry.
- Change each map's basic power/regeneration. Verify its other fields remain unchanged.
- Change both traction settings; verify exact tenths values, including signed synthetic fixtures in automated tests.
- Toggle bike lock and check configuration readback and status telemetry.
- Read/write each advanced curve with all 15 power and 15 regeneration samples. Confirm the real transport accepts a 68-byte write and a 64-byte response, without invented notification fragmentation.
- Navigate and manage local presets in FENR; verify these operations do not issue configuration mutation packets. Reads are allowed.
- Reconnect and confirm state survives. Reset the scenario and confirm defaults return.

## Failure profiles

Stop before changing a profile, then reconnect FENR. Return to Normal operation between independent cases.

| Profile | Expected check |
| --- | --- |
| Reject V2 authentication | No protected telemetry or configuration access |
| Delay configuration responses | Replies are held for six seconds; client timeout/recovery is visible |
| Never send configuration responses | Configuration is notification/write-only; no application reply arrives |
| Freeze telemetry values | Changing simulator state does not change sent samples until the profile is cleared |
| Incomplete speed packet | FENR handles a one-byte speed payload without a crash |
| Unsupported firmware | Older reported PIC firmware prevents configuration success |
| Reject advanced curve records | Unsupported record errors remain explicit |
| Acknowledge without applying | ATT/protocol success alone does not pass fresh-read confirmation |
| Failed traction reads | No background initialization; explicit user-selected writes may be exercised after the bounded read failure |

The failed-traction-read profile rejects type-8 reads until a valid type-8 write arrives in that session, then allows fresh confirmation. Reauthentication or scenario reset reinstates the read failure. Verify that FENR never initializes traction through a background write.

## Link loss and records

Stopping advertisements is not a disconnect primitive. The app removes services and invalidates its application session on Stop. For a physical link-loss check, manually interrupt Bluetooth and record the observed client behavior; do not claim exact motorcycle radio errors.

Record date, emulator/FENR revisions, Mac/iPhone OS versions, security profile, discovery, V2 outcome, negotiated payload sizes, observed values and blockers. Do not record real device identifiers or raw security bytes. Only successful physical checks justify the corresponding milestone tags.
