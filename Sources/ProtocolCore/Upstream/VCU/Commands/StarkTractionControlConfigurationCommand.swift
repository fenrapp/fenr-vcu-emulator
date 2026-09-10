import Foundation

public enum StarkTractionControlConfigurationCommand {
    public static let configurationType: UInt8 = 8
    public static let responseLength = 8
    public static let writePacketLength = 9
    public static let writeMode: UInt8 = 15
    public static let percentRange = 0.0 ... 100.0
    public static let rawValueRange = 0 ... 1_000

    public static func readPacket(mapIndex: Int) throws -> Data {
        guard StarkPowerModeConfigurationCommand.mapIndexes.contains(mapIndex) else {
            throw StarkProtocolError.invalidMapIndex(mapIndex)
        }
        return Data([0, configurationType, UInt8(mapIndex)])
    }

    public static func writePacket(
        mapIndex: Int,
        powerTractionPercent: Double,
        brakingTractionPercent: Double
    ) throws -> Data {
        try writePacket(
            mapIndex: mapIndex,
            powerRaw: rawValue(forPercent: powerTractionPercent),
            brakingRaw: rawValue(forPercent: brakingTractionPercent)
        )
    }

    public static func noOpWritePacket(
        configuration: StarkTractionControlConfigurationPayload
    ) throws -> Data {
        try writePacket(
            mapIndex: configuration.mapIndex,
            powerRaw: configuration.powerRaw,
            brakingRaw: configuration.brakingRaw
        )
    }

    public static func rawValue(forPercent percent: Double) throws -> Int {
        guard percent.isFinite,
              percentRange.contains(percent),
              percent.rounded() == percent
        else {
            throw StarkProtocolError.invalidTractionControlPercent(percent)
        }
        return Int((percent * 10).rounded())
    }

    public static func decodeResponse(
        _ data: Data,
        expectedMapIndex: Int
    ) throws -> StarkTractionControlConfigurationPayload {
        guard StarkPowerModeConfigurationCommand.mapIndexes.contains(expectedMapIndex) else {
            throw StarkProtocolError.invalidMapIndex(expectedMapIndex)
        }
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
        let mapIndex = Int(reader.u8(at: 3))
        guard mapIndex == expectedMapIndex else {
            throw StarkProtocolError.unexpectedMapIndex(expected: expectedMapIndex, actual: mapIndex)
        }
        return StarkTractionControlConfigurationPayload(
            mapIndex: mapIndex,
            powerRaw: Int(reader.i16(at: 4)),
            brakingRaw: Int(reader.i16(at: 6))
        )
    }

    private static func writePacket(
        mapIndex: Int,
        powerRaw: Int,
        brakingRaw: Int
    ) throws -> Data {
        guard StarkPowerModeConfigurationCommand.mapIndexes.contains(mapIndex) else {
            throw StarkProtocolError.invalidMapIndex(mapIndex)
        }
        guard rawValueRange.contains(powerRaw), powerRaw.isMultiple(of: 10) else {
            throw StarkProtocolError.invalidTractionControlRawValue(powerRaw)
        }
        guard rawValueRange.contains(brakingRaw), brakingRaw.isMultiple(of: 10) else {
            throw StarkProtocolError.invalidTractionControlRawValue(brakingRaw)
        }
        let power = Int16(powerRaw)
        let braking = Int16(brakingRaw)
        return Data([
            1,
            configurationType,
            1,
            UInt8(mapIndex),
            writeMode,
            UInt8(truncatingIfNeeded: power),
            UInt8(truncatingIfNeeded: power >> 8),
            UInt8(truncatingIfNeeded: braking),
            UInt8(truncatingIfNeeded: braking >> 8)
        ])
    }
}
