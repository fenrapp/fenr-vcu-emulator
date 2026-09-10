import Foundation

public struct AuthenticationVerifier: Sendable {
    private let builder: any StarkAuthenticationPayloadBuilding

    public init(builder: any StarkAuthenticationPayloadBuilding) {
        self.builder = builder
    }

    public func accepts(_ response: Data, nonce: Data, identity: EmulatedIdentity) -> Bool {
        guard response.count == StarkAuthenticationConstants.responseLength,
              let expected = try? builder.buildVersionTwo(
                vin: identity.vin, pairingDate: identity.pairingDate, nonce: nonce
              ) else { return false }
        return zip(response, expected).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
