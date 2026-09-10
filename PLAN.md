# FENR VCU Emulator - implementation proposal

Status: planning only, 2026-09-10. No BLE peripheral has been implemented or physically validated.

## Objective

Build a native macOS app that exposes the known Stark VCU BLE interface to a physical iPhone running FENR. The Mac owns a synthetic vehicle state, accepts protocol requests and publishes coherent telemetry. The final validation of vehicle behavior still happens on the motorcycle.

This is a behavioral protocol emulator, not execution of the original VCU firmware. VCU is the name used by the existing app and the new project folder; battery/BMS information is part of the interface it exposes.

## Findings from the current workspace

- FENR scans without a service filter and identifies bikes by advertised name. Discovery requires a valid VIN-shaped name; connection also supports matching suffixes. Use a synthetic identity, validated with StarkPairingIdentity, and verify that macOS advertises the complete name.
- StarkProtocol already contains the UUID catalog, pairing identity rules, PIN derivation, V2 authentication response builder, telemetry decoders and supported configuration commands.
- V2 authentication reads a 32-byte nonce, writes a 34-byte response, and receives an authentication-result notification. The emulator must validate the response against its configured synthetic identity and current challenge.
- Bluetooth bonding and the V2 exchange are separate layers. Reproducing V2 does not establish equivalent OS pairing behavior.
- BikeSDK describes Bike, Live, Battery, Charger, VCU and Inverter services. Its discovery list includes experimental characteristics; listing a UUID does not mean its payload semantics are known.
- Modules/BikeEmulator already simulates domain-level behavior for demo/debug use. It does not expose a real BLE peripheral. Its scenarios and state transitions are useful references.
- The iOS checkout contains uncommitted work, including startup/authentication changes. This proposal describes that working tree, not a frozen release. Freeze an agreed source revision before implementing compatibility fixtures.

## Feasibility and the first decision gate

Core Bluetooth provides CBPeripheralManager, mutable GATT services/characteristics, read/write callbacks and notifications. A native Mac peripheral is the preferred first implementation.

The first prototype must establish these points on the actual Mac and iPhone:

1. Publication of the required proprietary UUIDs succeeds.
2. The synthetic VIN remains discoverable despite advertising size limits. Start with the local name and only the essential advertised service; services can be discovered after connection without all being advertised.
3. Required read/write/notify properties and the system-managed CCCD satisfy FENR discovery.
4. The real V2 exchange succeeds and an invalid response is rejected.
5. Reads, notifications and configuration-sized writes fit the negotiated transport limits.
6. Link encryption works to the extent exposed by macOS, with its actual pairing UX documented separately.

Apple exposes encryption permissions but the reviewed peripheral API does not expose a way to select the motorcycle's derived pairing passkey. Do not promise an identical PIN dialog or bonding procedure. An application-authenticated profile without a link-encryption requirement may help isolate V2 during development; label that reduced-fidelity profile explicitly. It does not validate motorcycle bonding.

If macOS cannot meet a requirement essential to the intended testing, retain the same emulator engine and investigate a dedicated BLE peripheral with a controllable stack as an alternative radio backend. Select hardware only after the failed requirement is measured.

## Proposed architecture

```text
Physical iPhone / FENR
        <-> real BLE GATT
Mac BLE peripheral adapter
        <-> protocol requests and responses
Session/authentication engine + configuration handlers
        <-> synthetic vehicle state
Scenario engine / injected clock
        <-> macOS SwiftUI controls and activity log
```

- App: explicit dependency composition, window lifecycle and start/stop controls.
- BLEPeripheral: CBPeripheralManager ownership, GATT publication, dynamic reads, write batches, offsets, subscription tracking and notification backpressure.
- ProtocolEngine: session authentication, command decoding, response encoding, firmware profiles and protocol errors; no SwiftUI or Core Bluetooth types.
- VehicleSimulation: stateful battery, charging, ride and configuration behavior; deterministic scenarios with an injected clock and random source.
- Presentation: immutable screen models, semantic controls and a bounded event log with protocol summaries.
- Tests: pure engine tests, independent synthetic byte fixtures, transport doubles and a physical-device acceptance checklist.

One active application session initially. Isolate challenges and authorization by central, reject additional clients at the application layer, and assess actual link exclusivity in the prototype. Core Bluetooth can admit multiple centrals, so application rejection is not equivalent to radio-level refusal.

Own every timer/task and cancel queued work on stop/reset. Discard stale callbacks using session generations. Reconnects require fresh authentication, while vehicle configuration can survive reconnects. Define explicit reset-to-scenario and optional local persistence behavior.

## Reuse strategy

Keep this project separate from fenr-ios-app. Reuse the pure protocol definitions through a versioned Swift package when practical. StarkProtocol is currently a source module; there is no existing Package.swift to consume directly.

For the feasibility prototype, a documented local source reference can avoid an immediate refactor of the iOS repository. Before making the emulator independently reproducible, choose either a shared versioned package or a deliberately synchronized source subset with its origin revision recorded. Do not depend on the entire BikeSDK or app composition.

Use BikeEmulator as a behavioral reference rather than importing all its domain repository dependencies. Implement peripheral-side encoders and request handlers: existing client decoders alone are insufficient. Include independent expected-byte fixtures so a shared client/emulator mistake cannot pass only through round-trip tests.

## Delivery stages and acceptance

### 0. BLE feasibility slice

Minimal Mac app, one synthetic bike, essential GATT services, real V2 validation and adjustable battery/speed/status values.

Accepted when a physical iPhone discovers and connects through FENR's normal BLE path, authenticates, displays changing telemetry, disconnects and reconnects successfully. Record Mac/iPhone OS versions and the pairing limitations. Validate the largest planned payload early. Do not bypass FENR authentication to make this pass.

### 1. Useful daily dashboard simulator

Add Start/Stop, reset, scenario selection, speed, battery percentage, temperatures, active map and charging state. Provide parked, riding, charging and partial-telemetry scenarios, plus a readable event timeline.

Accepted when changes appear on the phone and related measurements remain coherent. Verify start/stop/restart and session cleanup. Do not invent rider-facing meanings for unknown fields.

### 2. Stateful configuration

Implement the supported 4005 transaction flows, separating ATT write acknowledgement from protocol status and subsequent read-back. Preserve firmware/capability profiles and the client's existing guards.

Start with charge power/target and base maps, then add guarded traction, bike lock and advanced curves. Preserve complete sibling values. Cover base-map selector normalization, both signed traction values, and both fifteen-sample advanced-curve series. Navigation and local preset actions should produce no vehicle writes in the event log.

Accepted when FENR reads a configuration, performs its required preparation/no-op checks, writes a change and confirms fresh emulator state. Include rejected writes and acknowledged-but-unapplied changes. Emulator success does not add physical validation evidence for traction, lock or advanced curves.

### 3. Reproducible failures and regression scenarios

Add delayed or missing application responses, rejected authentication, stale telemetry, malformed application payloads, unsupported firmware/capabilities and configurable read-back mismatches. Test a failed bounded traction read followed by an explicit user commit separately from the ordinary preparation path.

Separate application silence from actual radio disconnect. Stopping advertising is not a disconnect primitive. Use measured OS-supported teardown or manual Bluetooth interruption for physical link-loss tests; exact radio fault injection may require another backend.

Accepted when each scenario is repeatable and FENR recovers without stale updates or false success. Exercise the real Watch separately after the iPhone flow is stable; simultaneous-client fidelity is not an initial promise.

## Initial UI

A single window is enough: synthetic identity and firmware profile at the top, Start/Stop and connection/authentication status, telemetry controls, scenario selection and recent activity. Add configuration inspection and fault controls as their handlers become available. Keep UI copy in English and localizable.

## Coverage boundaries

High-value coverage: discovery, service discovery, V2 authentication, real Core Bluetooth reads/writes/subscriptions, payload decoding, configuration confirmation, lifecycle recovery and screen behavior.

Limited coverage: motorcycle PIN/bonding UX, radio timing/MTU behavior, exact disconnect reasons, interference, firmware defects, physical charging/motor behavior and uncharacterized protocol fields. A successful Mac test means compatibility with the implemented model.

Default to synthetic identities and generated data. Keep raw captures, real identifiers and security material out of this repository. Sanitized reference evidence can inform fixtures without copying private captures into the project. No cloud service is required for the local modeled V2 flow.

## Sources

- Local app: Modules/BikeSDK/Sources/CoreBluetooth/Coordinators/Connection/BikeBLEConnectionCoordinator.swift; Modules/BikeSDK/Sources/CoreBluetooth/Coordinators/Security/BikeBLESecurityHandshake.swift; Modules/BikeSDK/Sources/Constants/BikeBLEDiagnosticsProfile.swift.
- Local app: Modules/StarkProtocol/Sources/Authentication; Modules/StarkProtocol/Sources/VCU; Modules/BikeEmulator.
- Local research: bike-protocol-research/docs/ble/authentication.md and docs/ble/unknowns.md. Confirm exact ordering against the selected client revision and evidence; the working client and research narrative differ in nonce/subscription ordering.
- [Apple: peripheral role tasks](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonPeripheralRoleTasks/PerformingCommonPeripheralRoleTasks.html) documents service publication, advertising restrictions, ATT handling and notification queues.
- [Apple: CBPeripheralManager](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager) defines the native peripheral interface.
- [Apple: attribute permissions](https://developer.apple.com/documentation/corebluetooth/cbattributepermissions) documents optional encryption requirements.
- [Apple: stopAdvertising](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager/stopadvertising()) documents stopping advertisements.
