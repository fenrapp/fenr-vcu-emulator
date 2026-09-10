import CryptoKit
import Foundation

public enum StarkPin {
    public static func derive(
        vin: String,
        pairingDate: String = StarkPinConstants.fallbackPairingDate
    ) -> String {
        let normalizedVIN = StarkPairingIdentity.normalizedVIN(vin)
        let date = StarkPairingIdentity.normalizedDate(pairingDate)
        let key = "\(normalizedVIN)\(StarkPinConstants.separator)\(date)"
        let bytes = Array(SHA256.hash(data: Data(key.utf8)))
        let digits = [
            StarkPinConstants.firstDigit,
            StarkPinConstants.secondDigit,
            StarkPinConstants.thirdDigit,
            StarkPinConstants.fourthDigit
        ]

        let pin = digits.reduce(0) { result, rule in
            let transformedByte = Int(bytes[rule.index] ^ rule.xor) + Int(rule.add)
            let value = transformedByte % StarkPinConstants.decimalBase
            return result + value * rule.multiplier
        }

        return String(format: "%0\(StarkPinConstants.outputDigits)d", pin)
    }
}
