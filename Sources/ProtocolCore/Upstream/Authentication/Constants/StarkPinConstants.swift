public enum StarkPinConstants {
    public static let separator = "-"
    public static let fallbackPairingDate = "19700101"
    public static let pairingDateDigits = 8
    public static let decimalBase = 10
    public static let outputDigits = 6

    public static let firstDigit = StarkPinDigit(index: 3, xor: 197, add: 228, multiplier: 1)
    public static let secondDigit = StarkPinDigit(index: 14, xor: 236, add: 209, multiplier: 10)
    public static let thirdDigit = StarkPinDigit(index: 9, xor: 158, add: 100, multiplier: 100)
    public static let fourthDigit = StarkPinDigit(index: 15, xor: 179, add: 239, multiplier: 1000)
}

public struct StarkPinDigit: Sendable {
    public let index: Int
    public let xor: UInt8
    public let add: UInt8
    public let multiplier: Int
}
