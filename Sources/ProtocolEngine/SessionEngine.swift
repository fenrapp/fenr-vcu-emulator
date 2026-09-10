import Foundation
import ProtocolCore

@MainActor
public final class SessionEngine {
    public let identity: EmulatedIdentity
    public private(set) var generation: UInt64 = 0
    public private(set) var phase: SessionPhase = .idle
    public private(set) var central: UUID?
    private let verifier: AuthenticationVerifier
    private let nonceGenerator: any NonceGenerating
    private let clock: any SessionClock
    private var nonce: Data?
    private var challengedAt: TimeInterval = 0
    private var subscriptions: Set<CharacteristicID> = []
    private let challengeLifetime: TimeInterval = 30
    private var subscriptionDeadline: TimeInterval?

    public init(identity: EmulatedIdentity, verifier: AuthenticationVerifier,
                nonceGenerator: any NonceGenerating, clock: any SessionClock) {
        self.identity = identity
        self.verifier = verifier
        self.nonceGenerator = nonceGenerator
        self.clock = clock
    }

    public func reset() {
        generation &+= 1
        central = nil
        phase = .idle
        nonce = nil
        subscriptions.removeAll()
        subscriptionDeadline = nil
    }

    public func readChallenge(central candidate: UUID, offset: Int) throws -> Data {
        expireSession()
        guard offset >= 0 else { throw ProtocolFailure.invalidOffset }
        guard central == nil || central == candidate else { throw ProtocolFailure.busy }
        if offset == 0 {
            let next = nonceGenerator.generate()
            guard next.count == 32 else { throw ProtocolFailure.invalidLength }
            // The same central may retry authentication. Keep its actual CCCD subscriptions.
            generation &+= 1
            central = candidate
            nonce = next
            phase = .challenged
            challengedAt = clock.now()
        }
        guard let nonce, phase == .challenged else { throw ProtocolFailure.authenticationRequired }
        guard offset <= nonce.count else { throw ProtocolFailure.invalidOffset }
        return Data(nonce.dropFirst(offset))
    }

    public func authenticate(central candidate: UUID, response: Data, reject: Bool = false) throws -> ProtocolNotification {
        expireSession()
        guard central == candidate, phase == .challenged, let nonce else {
            throw ProtocolFailure.authenticationRequired
        }
        guard subscriptions.contains(.security) else { throw ProtocolFailure.unsupported }
        let accepted = verifier.accepts(response, nonce: nonce, identity: identity) && !reject
        self.nonce = nil
        phase = accepted ? .authenticated : .idle
        return ProtocolNotification(central: candidate, characteristic: .security,
                                    data: Data([accepted ? 1 : 0]), generation: generation)
    }

    public func subscribe(central candidate: UUID, characteristic: CharacteristicID) throws {
        expireSession()
        guard central == nil || central == candidate else { throw ProtocolFailure.busy }
        if characteristic != .security { try authorize(candidate) }
        if central == nil {
            central = candidate
            challengedAt = clock.now()
        }
        subscriptions.insert(characteristic)
        subscriptionDeadline = nil
    }

    public func unsubscribe(central candidate: UUID, characteristic: CharacteristicID) {
        guard central == candidate else { return }
        subscriptions.remove(characteristic)
        // FENR disables security notifications before subscribing to telemetry.
        guard subscriptions.isEmpty else { return }
        if characteristic == .security && phase == .authenticated {
            subscriptionDeadline = clock.now() + challengeLifetime
        } else {
            reset()
        }
    }

    public func authorize(_ candidate: UUID) throws {
        expireSession()
        guard central == candidate, phase == .authenticated else {
            throw ProtocolFailure.authenticationRequired
        }
    }

    public func notification(_ data: Data, characteristic: CharacteristicID, notBefore: TimeInterval = 0) -> ProtocolNotification? {
        expireSession()
        guard let central, phase == .authenticated, subscriptions.contains(characteristic) else { return nil }
        return ProtocolNotification(central: central, characteristic: characteristic, data: data, generation: generation, notBefore: notBefore)
    }

    public func isCurrent(_ notification: ProtocolNotification) -> Bool {
        expireSession()
        return notification.generation == generation && notification.central == central
            && subscriptions.contains(notification.characteristic)
            && (notification.characteristic == .security || phase == .authenticated)
    }

    private func expireSession() {
        guard central != nil else { return }
        if let subscriptionDeadline, clock.now() >= subscriptionDeadline {
            reset()
        } else if phase != .authenticated && clock.now() - challengedAt >= challengeLifetime {
            reset()
        }
    }
}
