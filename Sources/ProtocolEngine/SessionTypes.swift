import Foundation
import ProtocolCore

public enum ProtocolFailure: Error, Equatable, Sendable {
    case authenticationRequired, busy, invalidOffset, invalidLength, unsupported
}

public struct ProtocolNotification: Equatable, Sendable {
    public let central: UUID
    public let characteristic: CharacteristicID
    public let data: Data
    public let generation: UInt64
    public let notBefore: TimeInterval

    public init(central: UUID, characteristic: CharacteristicID, data: Data, generation: UInt64, notBefore: TimeInterval = 0) {
        self.central = central
        self.characteristic = characteristic
        self.data = data
        self.generation = generation
        self.notBefore = notBefore
    }
}

public protocol NonceGenerating: Sendable {
    func generate() -> Data
}

public struct SystemNonceGenerator: NonceGenerating {
    public init() {}
    public func generate() -> Data {
        var generator = SystemRandomNumberGenerator()
        return Data((0..<32).map { _ in UInt8.random(in: .min ... .max, using: &generator) })
    }
}

public protocol SessionClock: Sendable {
    func now() -> TimeInterval
}

public struct MonotonicSessionClock: SessionClock {
    public init() {}
    public func now() -> TimeInterval { ProcessInfo.processInfo.systemUptime }
}

public enum SessionPhase: Sendable { case idle, challenged, authenticated }
