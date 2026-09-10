import Foundation

public struct StarkByteReader: Sendable {
    private let data: Data

    public init(data: Data) {
        self.data = data
    }

    public func require(_ count: Int) throws {
        guard data.count >= count else {
            throw StarkProtocolError.payloadTooShort(expected: count, actual: data.count)
        }
    }

    public func u8(at offset: Int) -> UInt8 {
        data[data.index(data.startIndex, offsetBy: offset)]
    }

    public func u16(at offset: Int) -> UInt16 {
        UInt16(u8(at: offset)) | UInt16(u8(at: offset + 1)) << 8
    }

    public func i16(at offset: Int) -> Int16 {
        Int16(bitPattern: u16(at: offset))
    }

    public func u32(at offset: Int) -> UInt32 {
        UInt32(u8(at: offset))
            | UInt32(u8(at: offset + 1)) << 8
            | UInt32(u8(at: offset + 2)) << 16
            | UInt32(u8(at: offset + 3)) << 24
    }
}
