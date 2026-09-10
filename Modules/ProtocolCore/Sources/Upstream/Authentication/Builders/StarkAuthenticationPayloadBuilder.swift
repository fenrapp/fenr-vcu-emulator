import CryptoKit
import Foundation

public protocol StarkAuthenticationPayloadBuilding: Sendable {
    func buildVersionTwo(vin: String, pairingDate: String, nonce: Data) throws -> Data
}

public struct StarkAuthenticationPayloadBuilder: StarkAuthenticationPayloadBuilding {
    public init() {}

    public func buildVersionTwo(vin: String, pairingDate: String, nonce: Data) throws -> Data {
        guard nonce.count == StarkAuthenticationConstants.nonceLength else {
            throw StarkProtocolError.invalidNonceLength(
                expected: StarkAuthenticationConstants.nonceLength,
                actual: nonce.count
            )
        }

        let normalizedVIN = StarkPairingIdentity.normalizedVIN(vin)
        guard !normalizedVIN.isEmpty else {
            throw StarkProtocolError.invalidVIN
        }

        let normalizedDate = StarkPairingIdentity.normalizedDate(pairingDate)
        let identity = "\(normalizedVIN)\(StarkPinConstants.separator)\(normalizedDate)"
        let identityHash = Array(SHA256.hash(data: Data(identity.utf8)))
        let derivedKey = Data(StarkAuthenticationConstants.versionTwoRules.map { rule in
            let value = Int(identityHash[rule.index] ^ rule.xor) + Int(rule.add)
            return UInt8(value % StarkAuthenticationConstants.byteModulo)
        })

        var challenge = Data()
        challenge.reserveCapacity(
            StarkAuthenticationConstants.derivedKeyLength
                + StarkAuthenticationConstants.versionTwoHeader.count
                + StarkAuthenticationConstants.nonceLength
        )
        challenge.append(derivedKey)
        challenge.append(StarkAuthenticationConstants.versionTwoHeader)
        challenge.append(nonce)

        let digest = Data(SHA256.hash(data: challenge))
        var payload = StarkAuthenticationConstants.versionTwoHeader
        payload.append(digest)
        return payload
    }
}
