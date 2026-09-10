import Foundation

public struct SimulationViewState {
    public var scenarioID: String
    public var scenarioTitle: String
    public var battery: String
    public var speed: String
    public var deliveredPower: String
    public var requestedPower: String
    public var controls: [SimulationNumber]
    public var signals: [SimulationToggle]
    public var charging: Bool
    public var partial: Bool
    public var running: Bool
    public var presets: [PresetChoice]
}
