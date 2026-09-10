public enum StarkProtocolError: Error, Equatable, Sendable {
    case payloadTooShort(expected: Int, actual: Int)
    case invalidPayloadLength(expected: Int, actual: Int)
    case invalidBatteryLevel(Int)
    case invalidVIN
    case invalidNonceLength(expected: Int, actual: Int)
    case invalidMapIndex(Int)
    case invalidPowerModeHorsepower(Int)
    case invalidPowerModeTorque(Int)
    case invalidRegenerativeBrakingPercent(Int)
    case invalidTractionControlPercent(Double)
    case invalidTractionControlRawValue(Int)
    case invalidBikeLockStatus(UInt8)
    case invalidPowerModeCurve(Int)
    case unexpectedConfigurationType(expected: UInt8, actual: UInt8)
    case unexpectedMapIndex(expected: Int, actual: Int)
    case unexpectedConfigurationOperation(expected: UInt8, actual: UInt8)
    case configurationRequestFailed(status: UInt8)
}
