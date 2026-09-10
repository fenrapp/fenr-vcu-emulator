import Foundation
import Testing
@testable import ProtocolCore

@Test func syntheticIdentityAndIndependentDigest() throws {
    let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
    let verifier = AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder())
    #expect(verifier.accepts(AuthenticationFixture.response, nonce: Data(0..<32), identity: identity))
    #expect(!verifier.accepts(AuthenticationFixture.response, nonce: Data(repeating: 0, count: 32), identity: identity))
    #expect(!verifier.accepts(Data([1]), nonce: Data(0..<32), identity: identity))
    #expect(throws: StarkProtocolError.self) {
        try EmulatedIdentity(vin: "invalid", pairingDate: "19700101")
    }
}
