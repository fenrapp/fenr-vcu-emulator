# FENR VCU Emulator

Native macOS behavioral BLE peripheral. Do not modify the sibling iOS repository.
Use Swift 6, macOS 14, explicit dependency composition and pure value types where possible.
ProtocolCore owns wire definitions; VehicleSimulation owns synthetic state; ProtocolEngine owns sessions and protocol behavior; BLEPeripheral owns Core Bluetooth. UI owns only presentation models and semantic actions.
Use only synthetic identifiers. Never commit captures, credentials, real VINs, security payload logs or local signing values. Preserve upstream MIT notices.
Own and cancel all tasks/timers. Bound notification queues and activity logs. Reject stale session work and isolate authorization per central.
Modules and Features own their Tests/TestDoubles, Tests/Support factories and Tests/Fixtures.
Follow docs/architecture.md: App composes one session; Features own presentation; EmulatorDomain exposes contracts; EmulatorData implements runtime and storage; DesignSystem is SwiftUI-only.
Views consume immutable feature presentation and semantic intents. Keep infrastructure out of UI, inject collaborators, and keep user-facing copy in the owning feature catalog.
Use English localized UI copy. Keep component layout constants named.
Run scripts/check.sh before committing code. Inspect the native app for UI changes.
Use typed branches and conventional commits. No pushes, history rewrites or remote creation.
Only tag milestones after their acceptance checks pass. Mark physical checks pending until actually performed. Never claim emulation proves physical vehicle behavior.
