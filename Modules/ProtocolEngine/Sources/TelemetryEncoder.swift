import Foundation
import ProtocolCore
import VehicleSimulation

public struct TelemetryEncoder: Sendable {
    public init() {}

    public func encode(_ state: VehicleState, characteristic: CharacteristicID) throws -> Data {
        guard state.hasValidTelemetry else { throw ProtocolFailure.unsupported }
        if state.partialTelemetry && characteristic.isTelemetry && characteristic != .battery {
            throw ProtocolFailure.unsupported
        }
        switch characteristic {
        case .battery:
            return WireBytes.u16(state.batteryPercent) + WireBytes.u16(state.batteryHealthPercent) + WireBytes.u16(Int((state.dcBusVolts * 10).rounded()))
        case .speed:
            return WireBytes.u16(Int((state.speedKmh * 10).rounded())) + WireBytes.u16(0)
        case .status:
            var bytes = Data(repeating: 0, count: 18)
            let signals = state.signals
            let info = (state.isCharging ? 1 : 0) | (state.charging.connected ? 2 : 0)
                | (signals.inGear ? 8 : 0) | (signals.poweredOn ? 16 : 0)
            let indicators = (signals.highBeam ? 2 : 0) | (signals.rightIndicator ? 4 : 0)
                | (signals.leftIndicator ? 8 : 0) | (signals.checkEngine ? 4096 : 0)
            bytes.replaceSubrange(2..<4, with: WireBytes.u16(indicators))
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
            let telemetry = state.charging
            let requested = Int((telemetry.requestedCurrent * 10).rounded())
            let current = state.isCharging ? Int((telemetry.reportedCurrent * 10).rounded()) : 0
            return [requested, current, Int((telemetry.targetCellVolts * 10000).rounded()), charger.current, charger.power, charger.target / 10, Int(state.dcBusVolts), Int(state.dcBusVolts)]
                .reduce(into: Data()) { $0.append(WireBytes.u16($1)) }
                + Data([UInt8(telemetry.status), state.isCharging ? 1 : 0, UInt8(telemetry.type)])
        case .brake:
            return Data([5, 15, state.signals.brake ? 1 : 0, 0, 0, 0, 0, 0])
        case .versions:
            // Four-byte blocks: patch, minor, major, reserved. PIC 1.10.1; bottom 1.4.1.
            return Data([1, 10, 1, 0, 1, 0, 1, 0, 1, 4, 1, 0])
        default:
            throw ProtocolFailure.unsupported
        }
    }
}
