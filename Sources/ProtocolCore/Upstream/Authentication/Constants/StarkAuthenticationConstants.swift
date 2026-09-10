import Foundation

public enum StarkAuthenticationConstants {
    public static let nonceLength = 32
    public static let derivedKeyLength = 16
    public static let responseDigestLength = 32
    public static let responseLength = 34
    public static let byteModulo = 256
    public static let successCode: UInt8 = 0x01
    public static let versionTwoHeader = Data([0x02, 0x01])

    public static let versionTwoRules: [StarkAuthenticationByteRule] = [
        .init(index: 8, xor: 0x66, add: 0xF3),
        .init(index: 23, xor: 0x2F, add: 0x20),
        .init(index: 20, xor: 0x8A, add: 0x3A),
        .init(index: 2, xor: 0x53, add: 0xF7),
        .init(index: 6, xor: 0xD0, add: 0xD8),
        .init(index: 26, xor: 0xC0, add: 0xFF),
        .init(index: 1, xor: 0x2D, add: 0x99),
        .init(index: 19, xor: 0x3A, add: 0x51),
        .init(index: 21, xor: 0x6B, add: 0x15),
        .init(index: 31, xor: 0xB5, add: 0xF6),
        .init(index: 3, xor: 0x84, add: 0x3F),
        .init(index: 17, xor: 0x47, add: 0x23),
        .init(index: 10, xor: 0x8D, add: 0x14),
        .init(index: 9, xor: 0x56, add: 0xDA),
        .init(index: 13, xor: 0xC2, add: 0xF7),
        .init(index: 16, xor: 0xF0, add: 0xA4)
    ]
}

public struct StarkAuthenticationByteRule: Sendable {
    public let index: Int
    public let xor: UInt8
    public let add: UInt8

    public init(index: Int, xor: UInt8, add: UInt8) {
        self.index = index
        self.xor = xor
        self.add = add
    }
}
