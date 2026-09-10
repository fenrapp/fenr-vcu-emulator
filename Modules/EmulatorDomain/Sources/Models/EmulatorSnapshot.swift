import VehicleSimulation

public struct EmulatorSnapshot: Sendable {
    public enum Transport: String, Sendable { case stopped, starting, advertising, unavailable, unauthorized, failed }
    public enum Authentication: String, Sendable { case idle, challenged, authenticated }
    public var transport: Transport = .stopped
    public var authentication: Authentication = .idle
    public var running = false
    public var vehicle: VehicleState
    public var scenario: SimulationScenario = .parked
    public var fault: FaultSettings
    public var revisions: [ConfigurationBlock: UInt64] = [:]
    public var activity: [ActivityEvent] = []
    public var presets: [EmulatorPreset] = []
    public var generation: UInt64 = 0
    public init(vehicle: VehicleState, fault: FaultSettings) { self.vehicle = vehicle; self.fault = fault }
}
