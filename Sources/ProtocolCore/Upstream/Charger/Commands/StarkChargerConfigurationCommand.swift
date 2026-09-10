import Foundation

public enum StarkChargerConfigurationCommand {
    public static let configurationType: UInt8 = 4
    public static let readPacket = Data([0x00, 0x04])
    public static let responseLength = 19
    public static let writePacketLength = 13

    public static func encodeWrite(_ configuration: StarkChargerConfiguration) throws -> Data {
        var data = Data([0x01, 0x04, configuration.save])
        try appendUInt16LE(configuration.chargeCurrentDeciAmperes, to: &data)
        try appendUInt16LE(configuration.chargePowerWatts, to: &data)
        try appendUInt16LE(configuration.maximumStateOfChargeDeciPercent, to: &data)
        try appendUInt16LE(configuration.standardChargerMaximumPowerWatts, to: &data)
        try appendUInt16LE(configuration.backpackChargerMaximumPowerWatts, to: &data)
        return data
    }

    public static func decodeResponse(_ data: Data) throws -> StarkChargerConfiguration {
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
        return StarkChargerConfiguration(
            chargeCurrentDeciAmperes: Int(reader.u16(at: 3)),
            chargePowerWatts: Int(reader.u16(at: 5)),
            maximumStateOfChargeDeciPercent: Int(reader.u16(at: 7)),
            minimumCurrentDeciAmperes: Int(reader.u16(at: 9)),
            startTimeRaw: Int(reader.u16(at: 11)),
            rampTimeRaw: Int(reader.u16(at: 13)),
            standardChargerMaximumPowerWatts: Int(reader.u16(at: 15)),
            backpackChargerMaximumPowerWatts: Int(reader.u16(at: 17))
        )
    }

    private static func appendUInt16LE(_ value: Int, to data: inout Data) throws {
        guard (0 ... Int(UInt16.max)).contains(value) else {
            throw StarkProtocolError.invalidPayloadLength(expected: Int(UInt16.max), actual: value)
        }
        data.append(UInt8(value & 0xFF))
        data.append(UInt8((value >> 8) & 0xFF))
    }
}
