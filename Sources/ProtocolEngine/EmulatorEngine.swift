import Foundation
import ProtocolCore
import VehicleSimulation

@MainActor
public final class EmulatorEngine {
    public let session: SessionEngine
    public private(set) var state: VehicleState
    private let encoder: TelemetryEncoder
    private let simulator: ScenarioSimulator
    private let configurationHandler: ConfigurationHandler
    private var lastConfigurationResponse: (generation: UInt64, data: Data)?

    public init(session: SessionEngine, state: VehicleState, encoder: TelemetryEncoder, simulator: ScenarioSimulator, configurationHandler: ConfigurationHandler) {
        self.session = session
        self.state = state
        self.encoder = encoder
        self.simulator = simulator
        self.configurationHandler = configurationHandler
    }

    public func resetScenario(_ scenario: SimulationScenario) {
        state = simulator.initialState(for: scenario)
        lastConfigurationResponse = nil
    }
    public func advance(seconds: TimeInterval) { state = simulator.advance(state, seconds: seconds) }

    public func setState(_ state: VehicleState) { self.state = state }

    public func read(central: UUID, characteristic: CharacteristicID, offset: Int) throws -> Data {
        if characteristic == .security { return try session.readChallenge(central: central, offset: offset) }
        try session.authorize(central)
        let bytes: Data
        if characteristic == .configuration {
            guard let response = lastConfigurationResponse, response.generation == session.generation else {
                throw ProtocolFailure.unsupported
            }
            bytes = response.data
        } else {
            bytes = try encoder.encode(state, characteristic: characteristic)
        }
        guard offset >= 0, offset <= bytes.count else { throw ProtocolFailure.invalidOffset }
        return Data(bytes.dropFirst(offset))
    }

    public func write(central: UUID, characteristic: CharacteristicID, offset: Int,
                      value: Data) throws -> [ProtocolNotification] {
        guard offset == 0 else { throw ProtocolFailure.invalidOffset }
        if characteristic == .security {
            return [try session.authenticate(central: central, response: value)]
        }
        try session.authorize(central)
        guard characteristic == .configuration else { throw ProtocolFailure.unsupported }
        let response = try configurationHandler.handle(value, configuration: &state.configuration)
        lastConfigurationResponse = (session.generation, response)
        var result = [ProtocolNotification]()
        if let notification = session.notification(response, characteristic: .configuration) { result.append(notification) }
        result.append(contentsOf: telemetry())
        return result
    }

    public func subscribe(central: UUID, characteristic: CharacteristicID) throws -> ProtocolNotification? {
        try session.subscribe(central: central, characteristic: characteristic)
        guard characteristic != .security, characteristic != .configuration else { return nil }
        let bytes = try encoder.encode(state, characteristic: characteristic)
        return session.notification(bytes, characteristic: characteristic)
    }

    public func telemetry() -> [ProtocolNotification] {
        CharacteristicID.allCases.filter(\.isTelemetry).compactMap { characteristic in
            guard let data = try? encoder.encode(state, characteristic: characteristic) else { return nil }
            return session.notification(data, characteristic: characteristic)
        }
    }
}
