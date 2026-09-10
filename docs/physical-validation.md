# Physical validation checklist

## Evidence status

On 2026-09-10, before the 0.2.0 redesign, the user confirmed LightBlue discovery, V2 onboarding, recovery from Partial telemetry to Parked, and successful FENR close/reopen with dashboard data. The clean iPhone candidate was commit `3c5582dd8c095c56f06c1482ef2dba85d4b6bf81`, now merged into local main. Emulator corrections included name-only advertising and SOC on 6004. Earlier acceptance remains limited to those observed checks.

For 0.2.0, automatic tests and native UI inspection are recorded separately below. All new physical signal, charging, configuration and failure scenarios still require this checklist. No new acceptance milestone is justified by software implementation alone. No motorcycle write-validation claim is made.

### Native inspection, 2026-09-10

The four sections, numeric battery edit, charging configuration draft/Apply, delayed-response selection, activity copy, and preset save/load/rename were exercised in the native app. Copy produced plain text with version, scenario, fault, event origin and generation. Further visual and physical results are appended after final validation.

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
- Reconnect and confirm state survives. Reset the scenario and confirm configuration remains; Reset all values restores configuration defaults.

## Failure profiles

Stop before changing a profile that requires it, then reconnect FENR. Return to Normal operation between independent cases.

| Profile | Expected check |
| --- | --- |
| Reject V2 authentication | No protected telemetry or configuration access |
| Delay configuration responses | Replies are held for the selected delay; client timeout/recovery is visible |
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

## Redesign validation record

Environment: macOS 26.6.2, Xcode 26.6 (17F109), Swift 6 language mode, Apple Silicon. The current source passes 48 Swift package tests and the app mapper test, including storage failure rollback, dirty-draft conflicts and paused activity capture. Native inspection covered light/dark appearance, a 1100 x 760 window and an 800-pixel-wide minimum window, keyboard numeric entry, the curve chart, preset save/load/rename, and clipboard export. System appearance was restored after the check. Small icon representations were inspected. Reduce-transparency fallback is implemented and compiled; a full VoiceOver pass and runtime checks on macOS 14 remain pending.

Bluetooth testing of the redesigned executable encountered a pending macOS TCC authorization request after rebuilding the ad hoc binary. The Settings entry alone being enabled did not establish authorization for that executable. Resolve the prompt before continuing the physical checklist. This record does not claim new iPhone acceptance for 0.2.0.
