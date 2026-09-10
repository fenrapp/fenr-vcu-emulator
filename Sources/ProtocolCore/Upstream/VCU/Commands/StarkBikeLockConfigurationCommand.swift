import Foundation

public enum StarkBikeLockConfigurationCommand {
    public static let configurationType: UInt8 = 5
    public static let action: UInt8 = 0x83
    public static let lockType: UInt8 = 1
    public static let responseLength = 7
    public static let writePacketLength = 7

    public static var readPacket: Data {
        Data([0, configurationType])
    }

    public static func writePacket(
        isLocked: Bool,
        lockType: UInt8 = Self.lockType,
        timeoutSeconds: Int = 0
    ) -> Data {
        let timeout = UInt16(bitPattern: Int16(clamping: timeoutSeconds))
        return Data([
            1,
            configurationType,
            action,
            isLocked ? 1 : 0,
            lockType,
            UInt8(truncatingIfNeeded: timeout),
            UInt8(truncatingIfNeeded: timeout >> 8)
        ])
    }

    public static func noOpWritePacket(
        configuration: StarkBikeLockConfigurationPayload
    ) -> Data {
        writePacket(
            isLocked: configuration.isLocked,
            lockType: configuration.lockType,
            timeoutSeconds: configuration.timeoutSeconds
        )
    }

    public static func decodeResponse(_ data: Data) throws -> StarkBikeLockConfigurationPayload {
        guard data.count >= responseLength else {
            throw StarkProtocolError.payloadTooShort(expected: responseLength, actual: data.count)
        }
        let reader = StarkByteReader(data: data)
        let operation = reader.u8(at: 0)
        guard operation == 0 || operation == 2 else {
            throw StarkProtocolError.unexpectedConfigurationOperation(expected: 0, actual: operation)
        }
        let type = reader.u8(at: 1)
        guard type == configurationType else {
            throw StarkProtocolError.unexpectedConfigurationType(expected: configurationType, actual: type)
        }
        let status = reader.u8(at: 2)
        guard status == 0 else {
            throw StarkProtocolError.configurationRequestFailed(status: status)
        }
        let lockStatus = reader.u8(at: 3)
        guard lockStatus == 0 || lockStatus == 1 else {
            throw StarkProtocolError.invalidBikeLockStatus(lockStatus)
        }
        return StarkBikeLockConfigurationPayload(
            isLocked: lockStatus == 1,
            lockType: reader.u8(at: 4),
            timeoutSeconds: Int(reader.i16(at: 5))
        )
    }
}
