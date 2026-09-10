import Foundation

public enum StarkPowerCurveConfigurationCommand {
    public static let configurationType: UInt8 = 1
    public static let sampleCount = 15
    public static let responseLength = 64
    public static let writePacketLength = 68

    public static func readPacket(curve: Int) throws -> Data {
        try validateCurve(curve)
        return Data([0, configurationType, UInt8(curve)])
    }

    public static func writePacket(_ configuration: StarkPowerCurveConfigurationPayload) throws -> Data {
        try validateCurve(configuration.curve)
        guard configuration.power.count == sampleCount,
              configuration.regeneration.count == sampleCount,
              configuration.power.allSatisfy({ 0 ... 1_000 ~= $0 }),
              configuration.regeneration.allSatisfy({ 0 ... 1_000 ~= $0 }),
              configuration.power.contains(where: { $0 > 0 }) else {
            throw StarkProtocolError.invalidPowerModeCurve(configuration.curve)
        }
        var data = Data([1, configurationType, 1, UInt8(configuration.curve), 255, 127, 255, 127])
        for value in configuration.power + configuration.regeneration {
            data.append(UInt8(truncatingIfNeeded: value))
            data.append(UInt8(truncatingIfNeeded: value >> 8))
        }
        return data
    }

    public static func decodeResponse(_ data: Data, expectedCurve: Int) throws -> StarkPowerCurveConfigurationPayload {
        try validateCurve(expectedCurve)
        guard data.count >= responseLength else {
            throw StarkProtocolError.payloadTooShort(expected: responseLength, actual: data.count)
        }
        let reader = StarkByteReader(data: data)
        let operation = reader.u8(at: 0)
        guard operation == 0 || operation == 2 else {
            throw StarkProtocolError.unexpectedConfigurationOperation(expected: 0, actual: operation)
        }
        guard reader.u8(at: 1) == configurationType else {
            throw StarkProtocolError.unexpectedConfigurationType(expected: configurationType, actual: reader.u8(at: 1))
        }
        guard reader.u8(at: 2) == 0 else {
            throw StarkProtocolError.configurationRequestFailed(status: reader.u8(at: 2))
        }
        guard Int(reader.u8(at: 3)) == expectedCurve else {
            throw StarkProtocolError.invalidPowerModeCurve(Int(reader.u8(at: 3)))
        }
        return .init(
            curve: expectedCurve,
            power: (0 ..< sampleCount).map { Int(reader.u16(at: 4 + $0 * 4)) },
            regeneration: (0 ..< sampleCount).map { Int(reader.u16(at: 6 + $0 * 4)) }
        )
    }

    private static func validateCurve(_ curve: Int) throws {
        guard 1 ... 5 ~= curve else { throw StarkProtocolError.invalidPowerModeCurve(curve) }
    }
}
