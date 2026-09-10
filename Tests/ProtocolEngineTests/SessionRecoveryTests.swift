import Foundation
import Testing
import ProtocolCore
import VehicleSimulation
@testable import ProtocolEngine

@MainActor @Test func challengeExpiresAndAnotherClientCanAcquireSession() throws {
    let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
    let clock = ManualSessionClock()
    let session = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                nonceGenerator: FixedNonceGenerator(), clock: clock)
    let first = UUID(), second = UUID()
    _ = try session.readChallenge(central: first, offset: 0)
    clock.advance(31)
    _ = try session.readChallenge(central: second, offset: 0)
    #expect(session.central == second)
    #expect(throws: ProtocolFailure.authenticationRequired) { try session.authorize(first) }
    #expect(throws: ProtocolFailure.invalidOffset) { try session.readChallenge(central: second, offset: 33) }
}

@MainActor @Test func invalidResponseNeverUnlocksTelemetry() throws {
    let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
    let session = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                nonceGenerator: FixedNonceGenerator(), clock: ManualSessionClock())
    let client = UUID()
    _ = try session.readChallenge(central: client, offset: 0)
    try session.subscribe(central: client, characteristic: .security)
    let rejected = try session.authenticate(central: client, response: Data(repeating: 0, count: 34))
    #expect(rejected.data == Data([0]))
    #expect(throws: ProtocolFailure.authenticationRequired) { try session.subscribe(central: client, characteristic: .speed) }
    #expect(session.notification(Data([0]), characteristic: .speed) == nil)
    session.reset()
    #expect(!session.isCurrent(rejected))
}

@Test func telemetryWireValuesHaveIndependentExpectedBytes() throws {
    let encoder = TelemetryEncoder()
    let state = VehicleState(batteryPercent: 73, speedKmh: 25.5)
    #expect(try encoder.encode(state, characteristic: .battery) == Data([73, 0, 98, 0]))
    #expect(try encoder.encode(state, characteristic: .speed) == Data([255, 0, 0, 0]))
    let status = try encoder.encode(state, characteristic: .status)
    #expect(status.count == 18)
    #expect(status[8] == 0x18)
    #expect(try encoder.encode(state, characteristic: .versions) == Data([1,10,1,0,1,0,1,0,1,4,1,0]))
}
