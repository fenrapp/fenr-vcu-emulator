import Foundation
import VehicleSimulation

public enum EmulatorCommand: Sendable {
    case start(encrypted: Bool), stop, scenario(SimulationScenario), resetScenario, resetAll
    case telemetry(TelemetryEdit)
    case configure(ConfigurationBlock, draft: VehicleConfiguration, expectedRevision: UInt64)
    case fault(FaultSettings), clearActivity
    case savePreset(String), loadPreset(UUID), renamePreset(UUID, String), deletePreset(UUID)
}
public enum EmulatorOperationError: Error, Equatable { case stopRequired, invalidValues, conflict, storageUnavailable, presetUnavailable }
@MainActor public protocol EmulatorRepository: AnyObject {
    var snapshot: EmulatorSnapshot { get }
    func observe() -> AsyncStream<EmulatorSnapshot>
    func execute(_ command: EmulatorCommand) throws
}
@MainActor public protocol ClipboardWriting { func write(_ text: String) -> Bool }
@MainActor public protocol PresetStoring {
    func load() throws -> [EmulatorPreset]
    func save(_ presets: [EmulatorPreset]) throws
}
public protocol TickWaiting: Sendable { func wait() async throws }
