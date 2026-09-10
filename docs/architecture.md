# Architecture and contribution

## Boundaries

| Area | Responsibility |
| --- | --- |
| App | Explicit composition, one window, navigation and session lifecycle |
| Features/Simulation | Scenario controls and preset presentation |
| Features/Configuration | Validated drafts, conflict presentation and curves |
| Features/Failures | Fault controls and availability |
| Features/Activity | Filtering, selection and clipboard presentation |
| Modules/DesignSystem | SwiftUI surfaces, spacing, colors and controls |
| Modules/EmulatorDomain | Commands, snapshots, use cases and repository/platform contracts |
| Modules/EmulatorData | Observable runtime, telemetry edits, preset storage and clipboard adapter |
| Modules/ProtocolCore | Wire identifiers, binary definitions, authentication and firmware |
| Modules/VehicleSimulation | Synthetic state, deterministic simulation and configuration validation |
| Modules/ProtocolEngine | Authorization, protocol transactions and response generation |
| Modules/BLEPeripheral | Core Bluetooth GATT publication and bounded notification transport |

Each module owns Sources and Tests. Feature code groups Models, Mappers, ViewModels, Support and UI; UI components are grouped by function. Catalogs belong to each feature. Visual components accept feature-owned presentation and semantic callbacks, with infrastructure confined to view models and composition. Mappers prepare labels, units, grouped fields, chart points and action availability.

The composition root builds the entire object graph once. The runtime owns one ticker and transport-event observer. Feature observers are structured SwiftUI tasks, cancelled on navigation; they never own the server. Each snapshot observer gets its own bounded stream. Transport events and pending replies are checked against session generation. Stop/restart cancels prior work; deinitialization cancels tasks and releases the server.

Configuration uses shared validation for local edits and BLE writes. Local block commits compare a revision, replace only that block and normalize map selectors. Preset writes validate a complete candidate before atomic file replacement. No automatic preset restoration or background configuration initialization occurs.

## Design provenance

The feature/domain/data folder organization, separation of mappers and view models, semantic surfaces and spacing conventions were reviewed against committed FENR iOS revision `3c5582dd8c095c56f06c1482ef2dba85d4b6bf81`. The emulator's implementations are local; there is no path dependency. Protocol source provenance and retained MIT notices are listed in THIRD_PARTY_NOTICES.md and Modules/ProtocolCore/UpstreamManifest.json.

Liquid Glass is availability-gated to macOS 26. Earlier systems use native materials. Reduce Transparency uses an opaque surface; the interface has no custom motion that must be disabled. Text uses system typography, monospaced measurements, named layout constants and native keyboard controls.

The macOS icon uses the original dark FENR iPhone icon as the source for a cyan recolor. Source attribution is recorded in THIRD_PARTY_NOTICES.md. Standard macOS icon sizes are included in App/Resources/Assets.xcassets. It contains no vendor motorcycle asset.

## Contribution

Use typed topic branches and small conventional commits. Run scripts/check.sh and inspect changed UI before committing code; review git diff --cached. Integrate with fast-forward merge, then delete merged branches. Push only when explicitly authorized, preserve history and leave acceptance tags pending until required physical checks pass.

Inject collaborators at composition. Keep replaceable services out of stored-property defaults. Own tasks and guard mutations after suspension against cancellation and stale generations. Place doubles under the owning Tests/TestDoubles, factories under Tests/Support and immutable inputs under Tests/Fixtures. Do not commit real motorcycle identifiers, credentials, captures, generated projects or signing material.
