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
    private let clock: any SessionClock
    public private(set) var fault: FaultScenario = .none
    public private(set) var delaySeconds: TimeInterval = 6
    public private(set) var affectedTelemetry: Set<CharacteristicID> = Set(CharacteristicID.allCases.filter(\.isTelemetry))
    private var frozenTelemetry: VehicleState?
    private var tractionRecoveredGeneration: UInt64?
    public var configurationReadable: Bool { fault != .missingResponses }
    public var responseDelay: TimeInterval { fault == .delayedResponses ? delaySeconds : 0 }
    private var lastConfigurationResponse: (generation: UInt64, data: Data)?

    public init(session: SessionEngine, state: VehicleState, encoder: TelemetryEncoder, simulator: ScenarioSimulator, configurationHandler: ConfigurationHandler, clock: any SessionClock) {
        self.session = session
        self.state = state
        self.encoder = encoder
        self.simulator = simulator
        self.configurationHandler = configurationHandler
        self.clock = clock
    }

    public func setFault(_ fault: FaultScenario, delay: TimeInterval = 6, affected: Set<CharacteristicID> = Set(CharacteristicID.allCases.filter(\.isTelemetry))) {
        delaySeconds = delay.isFinite ? min(30, max(0, delay)) : 6
        affectedTelemetry = affected
        session.invalidatePendingResponses()
        self.fault = fault
        tractionRecoveredGeneration = nil
        frozenTelemetry = fault == .staleTelemetry ? state : nil
        lastConfigurationResponse = nil
    }

    private func encoded(_ characteristic: CharacteristicID) throws -> Data {
        if characteristic == .versions && fault == .unsupportedFirmware {
            return Data([0,0,1,0,1,0,1,0,1,4,1,0])
        }
        if characteristic == .speed && fault == .malformedTelemetry { return Data([0]) }
        return try encoder.encode(affectedTelemetry.contains(characteristic) ? (frozenTelemetry ?? state) : state,
                                  characteristic: characteristic)
    }

    public func resetScenario(_ scenario: SimulationScenario) {
        session.invalidatePendingResponses()
        let configuration = state.configuration
        state = simulator.initialState(for: scenario)
        state.configuration = configuration
        tractionRecoveredGeneration = nil
        lastConfigurationResponse = nil
        if fault == .staleTelemetry { frozenTelemetry = state }
    }
    public func advance(seconds: TimeInterval) { state = simulator.advance(state, seconds: seconds) }

    public func setState(_ state: VehicleState) { self.state = state }

    public func read(central: UUID, characteristic: CharacteristicID, offset: Int) throws -> Data {
        if characteristic == .security { return try session.readChallenge(central: central, offset: offset) }
        try session.authorize(central)
        let bytes: Data
        if characteristic == .configuration {
            guard configurationReadable, let response = lastConfigurationResponse, response.generation == session.generation else {
                throw ProtocolFailure.unsupported
            }
            bytes = response.data
        } else {
            bytes = try encoded(characteristic)
        }
        guard offset >= 0, offset <= bytes.count else { throw ProtocolFailure.invalidOffset }
        return Data(bytes.dropFirst(offset))
    }

    public func write(central: UUID, characteristic: CharacteristicID, offset: Int,
                      value: Data) throws -> [ProtocolNotification] {
        guard offset == 0 else { throw ProtocolFailure.invalidOffset }
        if characteristic == .security {
            return [try session.authenticate(central: central, response: value, reject: fault == .rejectedAuthentication)]
        }
        try session.authorize(central)
        guard characteristic == .configuration else { throw ProtocolFailure.unsupported }
        guard fault != .unsupportedFirmware else { throw ProtocolFailure.unsupported }
        let bytes = Array(value)
        if fault == .unsupportedCapabilities && bytes.count > 1 && bytes[1] == 1 { throw ProtocolFailure.unsupported }
        if fault == .failedTractionRead && bytes.starts(with: [0,8])
            && tractionRecoveredGeneration != session.generation { throw ProtocolFailure.unsupported }
        var candidate = state.configuration
        let response = try configurationHandler.handle(value, configuration: &candidate)
        if fault != .unappliedWrites { state.configuration = candidate }
        if fault == .failedTractionRead && bytes.starts(with: [1,8]) { tractionRecoveredGeneration = session.generation }
        if fault == .missingResponses {
            lastConfigurationResponse = nil
            return []
        }
        lastConfigurationResponse = (session.generation, response)
        var result = [ProtocolNotification]()
        if let notification = session.notification(response, characteristic: .configuration, notBefore: clock.now() + responseDelay) { result.append(notification) }
        result.append(contentsOf: telemetry())
        return result
    }

    public func subscribe(central: UUID, characteristic: CharacteristicID) throws -> ProtocolNotification? {
        try session.subscribe(central: central, characteristic: characteristic)
        guard characteristic != .security, characteristic != .configuration else { return nil }
        guard let bytes = try? encoded(characteristic) else { return nil }
        return session.notification(bytes, characteristic: characteristic)
    }

    public func telemetry() -> [ProtocolNotification] {
        CharacteristicID.allCases.filter(\.isTelemetry).compactMap { characteristic in
            guard let data = try? encoded(characteristic) else { return nil }
            return session.notification(data, characteristic: characteristic)
        }
    }
}
