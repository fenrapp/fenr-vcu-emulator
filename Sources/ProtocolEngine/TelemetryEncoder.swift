import Foundation
import ProtocolCore
import VehicleSimulation

public struct TelemetryEncoder: Sendable {
    public init() {}

    public func encode(_ state: VehicleState, characteristic: CharacteristicID) throws -> Data {
        if state.partialTelemetry && characteristic.isTelemetry && characteristic != .battery {
            throw ProtocolFailure.unsupported
        }
        switch characteristic {
        case .battery:
            return WireBytes.u16(state.batteryPercent) + WireBytes.u16(98)
        case .speed:
            return WireBytes.u16(Int((state.speedKmh * 10).rounded())) + WireBytes.u16(0)
        case .status:
            var bytes = Data(repeating: 0, count: 18)
            let info: UInt16 = state.isCharging ? 0x13 : (state.speedKmh > 0 ? 0x18 : 0x10)
            bytes.replaceSubrange(8..<10, with: WireBytes.u16(Int(info)))
            bytes[10] = state.configuration.lock.isLocked ? 1 : 0
            bytes.replaceSubrange(11..<13, with: WireBytes.u16(state.configuration.lock.timeout))
            return bytes
        case .map:
            return Data([UInt8(state.mapIndex)])
        case .totals:
            return WireBytes.u32(UInt32(min(Double(UInt32.max), max(0, state.odometerMeters)))) + Data(repeating: 0, count: 12)
        case .batteryTemperatures:
            return (0..<12).reduce(into: Data()) { bytes, _ in
                bytes.append(WireBytes.u16(Int(state.temperatureCelsius * 10)))
            } + Data([0xFF, 0x0F, 12])
        case .inverterTemperatures:
            return (0..<8).reduce(into: Data()) { bytes, _ in
                bytes.append(WireBytes.u16(Int(state.temperatureCelsius * 10)))
            }
        case .charger:
            let charger = state.configuration.charger
            let current = state.isCharging ? min(charger.current, charger.power * 10 / 360) : 0
            return [current, current, 42000, charger.current, charger.power, charger.target / 10, 360, 360]
                .reduce(into: Data()) { $0.append(WireBytes.u16($1)) }
                + Data([0, state.isCharging ? 1 : 0, 0])
        case .versions:
            // Four-byte blocks: patch, minor, major, reserved. PIC 1.10.1; bottom 1.4.1.
            return Data([1, 10, 1, 0, 1, 0, 1, 0, 1, 4, 1, 0])
        default:
            throw ProtocolFailure.unsupported
        }
    }
}
