import Foundation
import Testing
import ProtocolCore
@testable import ProtocolEngine

@MainActor @Test func authenticationAndReplayProtection() throws {
    let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
    let builder = StarkAuthenticationPayloadBuilder()
    let engine = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: builder),
                               nonceGenerator: FixedNonceGenerator(), clock: MonotonicSessionClock())
    let client = UUID()
    #expect(throws: ProtocolFailure.authenticationRequired) { try engine.authorize(client) }
    let nonce = try engine.readChallenge(central: client, offset: 0)
    #expect(try engine.readChallenge(central: client, offset: 16) == Data(16..<32))
    #expect(throws: ProtocolFailure.busy) { try engine.readChallenge(central: UUID(), offset: 0) }
    try engine.subscribe(central: client, characteristic: .security)
    let response = try builder.buildVersionTwo(vin: identity.vin, pairingDate: identity.pairingDate, nonce: nonce)
    let success = try engine.authenticate(central: client, response: response)
    #expect(success.data == Data([1]))
    try engine.authorize(client)
    #expect(throws: ProtocolFailure.authenticationRequired) { try engine.authenticate(central: client, response: response) }
    engine.unsubscribe(central: client, characteristic: .security)
    try engine.subscribe(central: client, characteristic: .battery)
    let sample = try #require(engine.notification(Data([70,0]), characteristic: .battery))
    #expect(engine.isCurrent(sample))
    engine.unsubscribe(central: client, characteristic: .battery)
    #expect(!engine.isCurrent(sample))
    #expect(throws: ProtocolFailure.authenticationRequired) { try engine.authorize(client) }
}
