import Foundation
import ProtocolCore
import VehicleSimulation

public struct TelemetryEncoder: Sendable {
    public init() {}

    public func encode(_ state: VehicleState, characteristic: CharacteristicID) throws -> Data {
        switch characteristic {
        case .battery:
            return WireBytes.u16(state.batteryPercent) + WireBytes.u16(98)
        case .speed:
            return WireBytes.u16(Int((state.speedKmh * 10).rounded())) + WireBytes.u16(0)
        case .status:
            var bytes = Data(repeating: 0, count: 18)
            let info: UInt16 = state.isCharging ? 0x13 : (state.speedKmh > 0 ? 0x18 : 0x10)
            bytes.replaceSubrange(8..<10, with: WireBytes.u16(Int(info)))
            return bytes
        case .map:
            return Data([UInt8(state.mapIndex)])
        case .totals:
            return WireBytes.u32(state.odometerMeters) + Data(repeating: 0, count: 12)
        case .versions:
            // Four-byte blocks: patch, minor, major, reserved. PIC 1.10.1; bottom 1.4.1.
            return Data([1, 10, 1, 0, 1, 0, 1, 0, 1, 4, 1, 0])
        default:
            throw ProtocolFailure.unsupported
        }
    }
}
