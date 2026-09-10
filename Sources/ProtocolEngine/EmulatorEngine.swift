import Foundation
import ProtocolCore
import VehicleSimulation

@MainActor
public final class EmulatorEngine {
    public let session: SessionEngine
    public private(set) var state: VehicleState
    private let encoder: TelemetryEncoder

    public init(session: SessionEngine, state: VehicleState, encoder: TelemetryEncoder) {
        self.session = session
        self.state = state
        self.encoder = encoder
    }

    public func setState(_ state: VehicleState) { self.state = state }

    public func read(central: UUID, characteristic: CharacteristicID, offset: Int) throws -> Data {
        if characteristic == .security { return try session.readChallenge(central: central, offset: offset) }
        try session.authorize(central)
        let bytes = try encoder.encode(state, characteristic: characteristic)
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
        throw ProtocolFailure.unsupported
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
