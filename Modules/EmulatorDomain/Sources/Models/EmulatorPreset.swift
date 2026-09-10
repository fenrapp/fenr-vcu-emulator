import Foundation
import VehicleSimulation

public struct EmulatorPreset: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var scenario: SimulationScenario
    public var vehicle: VehicleState
    public var faults: FaultSettings
    public init(id: UUID, name: String, scenario: SimulationScenario, vehicle: VehicleState, faults: FaultSettings) {
        self.id = id; self.name = name; self.scenario = scenario; self.vehicle = vehicle; self.faults = faults
    }
}
