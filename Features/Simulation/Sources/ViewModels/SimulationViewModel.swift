import Foundation
import Observation
import EmulatorDomain
import VehicleSimulation

@MainActor @Observable public final class SimulationViewModel {
    public private(set) var state: SimulationViewState
    public private(set) var message: String?
    private let useCases: EmulatorUseCases
    private let mapper: SimulationMapper
    public init(useCases: EmulatorUseCases, mapper: SimulationMapper) {
        self.useCases = useCases; self.mapper = mapper; self.state = mapper.map(useCases.current)
    }
    public func observe() async {
        for await value in useCases.observe() { guard !Task.isCancelled else { return }; state = mapper.map(value) }
    }
    public func selectScenario(_ id: String) { if let value = SimulationScenario(rawValue: id) { send(.scenario(value)) } }
    public func reset() { send(.resetScenario) }
    public func resetAll() { send(.resetAll) }
    public func stopMovement() { send(.telemetry(.stopMovement)) }
    public func interruptCharging() { send(.telemetry(.interruptCharging)) }
    public func number(_ id: String, _ value: Double) {
        guard value.isFinite, let control = state.controls.first(where: { $0.id == id }), control.range.contains(value) else {
            message = simulationText("Enter a value within the displayed range."); return
        }
        if id == "chargePower" || id == "chargeTarget" {
            let snapshot = useCases.current
            var draft = snapshot.vehicle.configuration
            if id == "chargePower" { draft.charger.power = Int(value.rounded()) }
            else { draft.charger.target = Int(value.rounded()) * 10 }
            send(.configure(.charger, draft: draft, expectedRevision: snapshot.revisions[.charger, default: 0])); return
        }
        let edit: TelemetryEdit
        switch id {
        case "battery": edit = .battery(Int(value.rounded()))
        case "health": edit = .health(Int(value.rounded()))
        case "voltage": edit = .voltage(value)
        case "temperature": edit = .temperature(value)
        case "odometer": edit = .odometer(value * 1000)
        case "speed": edit = .speed(value)
        case "map": edit = .map(Int(value.rounded()) - 1)
        case "requestedCurrent": edit = .requestedCurrent(value)
        case "reportedCurrent": edit = .reportedCurrent(value)
        case "targetCellVoltage": edit = .targetCellVoltage(value)
        case "chargerType": edit = .chargerType(Int(value.rounded()))
        case "chargerStatus": edit = .chargerStatus(Int(value.rounded()))
        default: return
        }
        send(.telemetry(edit))
    }
    public func toggle(_ id: String, _ value: Bool) {
        let edit: TelemetryEdit
        switch id {
        case "power": edit = .power(value)
        case "gear": edit = .gear(value)
        case "left": edit = .left(value)
        case "right": edit = .right(value)
        case "hazards": edit = .hazards(value)
        case "highBeam": edit = .highBeam(value)
        case "brake": edit = .brake(value)
        case "checkEngine": edit = .checkEngine(value)
        case "chargerConnected": edit = .chargerConnected(value)
        case "charging": edit = .charging(value)
        default: return
        }
        send(.telemetry(edit))
    }
    public func savePreset(_ name: String) { send(.savePreset(name)) }
    public func loadPreset(_ id: UUID) { send(.loadPreset(id)) }
    public func renamePreset(_ id: UUID, name: String) { send(.renamePreset(id, name)) }
    public func deletePreset(_ id: UUID) { send(.deletePreset(id)) }
    private func send(_ command: EmulatorCommand) {
        do { try useCases.execute(command); message = nil; state = mapper.map(useCases.current) }
        catch { message = simulationText("The change could not be applied. Check the values and stop Bluetooth before loading a preset.") }
    }
}
