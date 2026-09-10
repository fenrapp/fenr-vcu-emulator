# User guide

## Simulation

The persistent session bar shows scenario, transport, authentication, active fault and Start/Stop. Command-Return starts or stops the single server. Navigation never creates another Bluetooth session. The activity summary opens the complete log.

Scenario controls apply immediately. Use a slider or edit its numeric field and press Return. Changing scenario resets its controls while preserving configuration. **Reset scenario** does the same for the current scenario; **Reset all values** also restores configuration. Neither action clears the selected fault. Stop pauses evolution and invalidates the session. Reconnects preserve current state.

- **Parked:** battery, health, DC voltage, temperatures, odometer, active map, ignition and signals. Speed remains zero and charging is off.
- **Riding:** adds speed and gear. Indicators, hazards, high beam, brake and check-engine signals can be toggled individually. **Stop movement** sets speed to zero; brake only changes its signal.
- **Charging:** connected and charging are separate states. Requested and delivered current, battery voltage, target cell voltage, power limit, charge target and charger type are adjustable. Calculated powers use the transmitted voltage/current. **Interrupt charging** zeros delivered current and charging while retaining connection. Type/status raw controls are diagnostic: an arbitrary value does not imply a named error in FENR.
- **Partial telemetry:** deliberately sends battery only. FENR can remain on Securing or Waiting for live telemetry because five startup datasets are absent. The persistent warning offers a return to Parked.

Battery evolution is accelerated to one percentage point per simulated minute. Odometry follows the selected speed. These are deterministic test behaviors, not a battery or vehicle dynamics model. Signals are transmitted only through known protocol fields; the client decides which ones it presents.

## Configuration

Choose charging, lock, any of five maps, five traction records or five curve pairs. Each block has a separate draft. **Apply** validates and commits the entire block atomically. **Cancel / Reload** discards the draft. Navigation and drafting do not send BLE writes. Both 15-point curve series have a chart and editable sample table.

A block modified over Bluetooth while its draft is open must be reloaded before applying. Other blocks remain intact. Charge target is a whole percent; traction and curve values support tenths. Raw diagnostic fields retain their documented integer bounds. Unsupported commands fail explicitly.

## Failures

Authentication, GATT readability and capability profiles require a stopped server. Live response/telemetry faults can change during a session; changing them invalidates pending replies. Delays support 0-30 seconds. Freeze telemetry selects the affected datasets. Returning to No fault restores ordinary behavior.

Application silence is distinct from link loss. Stopping advertisements does not prove disconnection. Follow the physical checklist for real link-loss tests.

## Presets

Enter a name and choose **Save new** to capture scenario, controls, configuration and fault settings. Choose a saved preset to load, rename or delete it. Loading requires Bluetooth stopped. Presets never contain identity, credentials or activity. Startup does not automatically restore the last preset.

Storage is an atomic schema-versioned JSON document, limited to 100 presets, with validation before changing live state. Corrupt or incompatible files remain unchanged and produce a visible activity error. Compiler cleanup never touches them.

## Activity

Activity retains the most recent 1000 structured events. Search and category/severity filters narrow the table. Select rows for **Copy selected**, or use **Copy filtered** / **Copy all**. **Pause display** freezes the visible rows while capture continues. Unpausing catches up; Copy all always includes current captured events. Clear empties the log.

Export includes application version, current scenario/fault, timestamps, category, severity, origin and session generation. Transactions report operation, characteristic and byte count, never security payloads or device identifiers. Repetitive simulation ticks are summarized. Copy the log after reproducing an issue and include what you expected to happen.
