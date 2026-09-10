import Foundation

public struct EmulatedIdentity: Sendable {
    public let vin: String
    public let pairingDate: String

    public init(vin: String, pairingDate: String) throws {
        guard StarkPairingIdentity.isValidVIN(vin) else { throw StarkProtocolError.invalidVIN }
        self.vin = StarkPairingIdentity.normalizedVIN(vin)
        self.pairingDate = StarkPairingIdentity.normalizedDate(pairingDate)
    }

    public var pin: String { StarkPin.derive(vin: vin, pairingDate: pairingDate) }
}
