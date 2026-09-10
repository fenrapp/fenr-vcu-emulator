import Foundation

public enum StarkPowerModeConfigurationCommand {
    public static let mapIndexes = 0 ... 4
    public static let configurationType: UInt8 = 0
    public static let responseLength = 9
    public static let writePacketLength = 9
    public static let horsepowerRange = 10 ... 80
    public static let regenerationRange = -100 ... 100

    public static func readPacket(mapIndex: Int) throws -> Data {
        guard mapIndexes.contains(mapIndex) else {
            throw StarkProtocolError.invalidMapIndex(mapIndex)
        }
        return Data([0, configurationType, UInt8(mapIndex)])
    }

    public static func writePacket(
        mapIndex: Int,
        horsepower: Int,
        regenerativeBrakingPercent: Int,
        curve: Int
    ) throws -> Data {
        try requireMapIndex(mapIndex)
        guard horsepowerRange.contains(horsepower) else {
            throw StarkProtocolError.invalidPowerModeHorsepower(horsepower)
        }
        guard regenerationRange.contains(regenerativeBrakingPercent) else {
            throw StarkProtocolError.invalidRegenerativeBrakingPercent(regenerativeBrakingPercent)
        }
        let torqueRaw = Int((Double(horsepower) * 1.25).rounded())
        return try writePacket(
            mapIndex: mapIndex,
            torqueRaw: torqueRaw,
            regenerationRaw: regenerativeBrakingPercent,
            curve: curve
        )
    }

    public static func noOpWritePacket(
        configuration: StarkPowerModeConfigurationPayload
    ) throws -> Data {
        try writePacket(
            mapIndex: configuration.mapIndex,
            torqueRaw: configuration.torqueRaw,
            regenerationRaw: configuration.regenerationRaw,
            curve: normalizedWriteCurve(mapIndex: configuration.mapIndex)
        )
    }

    public static func normalizedWriteCurve(mapIndex: Int) throws -> Int {
        try requireMapIndex(mapIndex)
        return mapIndex + 1
    }

    public static func isSupportedReadCurve(_ curve: Int, mapIndex: Int) -> Bool {
        guard mapIndexes.contains(mapIndex) else {
            return false
        }
        return curve == 0 || curve == mapIndex + 1
    }

    public static func decodeResponse(
        _ data: Data,
        expectedMapIndex: Int
    ) throws -> StarkPowerModeConfigurationPayload {
        try requireMapIndex(expectedMapIndex)
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
        return StarkPowerModeConfigurationPayload(
            mapIndex: mapIndex,
            torqueRaw: Int(reader.i16(at: 4)),
            regenerationRaw: Int(reader.i16(at: 6)),
            curve: Int(reader.u8(at: 8))
        )
    }

    private static func requireMapIndex(_ mapIndex: Int) throws {
        guard mapIndexes.contains(mapIndex) else {
            throw StarkProtocolError.invalidMapIndex(mapIndex)
        }
    }

    private static func writePacket(
        mapIndex: Int,
        torqueRaw: Int,
        regenerationRaw: Int,
        curve: Int
    ) throws -> Data {
        try requireMapIndex(mapIndex)
        guard Int(Int16.min) ... Int(Int16.max) ~= torqueRaw else {
            throw StarkProtocolError.invalidPowerModeTorque(torqueRaw)
        }
        guard Int(Int16.min) ... Int(Int16.max) ~= regenerationRaw else {
            throw StarkProtocolError.invalidRegenerativeBrakingPercent(regenerationRaw)
        }
        guard Int(UInt8.min) ... Int(UInt8.max) ~= curve else {
            throw StarkProtocolError.invalidPowerModeCurve(curve)
        }
        let torque = Int16(torqueRaw)
        let regeneration = Int16(regenerationRaw)
        return Data([
            1,
            configurationType,
            UInt8(mapIndex),
            1,
            UInt8(truncatingIfNeeded: torque),
            UInt8(truncatingIfNeeded: torque >> 8),
            UInt8(truncatingIfNeeded: regeneration),
            UInt8(truncatingIfNeeded: regeneration >> 8),
            UInt8(curve)
        ])
    }
}
