import Foundation
import ProtocolCore
import VehicleSimulation

public struct ConfigurationHandler: Sendable {
    public init() {}

    public func handle(_ data: Data, configuration: inout VehicleConfiguration) throws -> Data {
        let bytes = Array(data)
        guard bytes.count >= 2 else { throw ProtocolFailure.invalidLength }
        guard bytes[0] == 0 || bytes[0] == 1 else { throw ProtocolFailure.unsupported }
        var candidate = configuration
        let response: Data
        switch bytes[1] {
        case 1: response = try curve(bytes, configuration: &candidate)
        case 0: response = try baseMap(bytes, configuration: &candidate)
        case 4: response = try charger(bytes, configuration: &candidate)
        case 8: response = try traction(bytes, configuration: &candidate)
        case 5: response = try lock(bytes, configuration: &candidate)
        default: throw ProtocolFailure.unsupported
        }
        configuration = candidate
        return response
    }

    private func baseMap(_ bytes: [UInt8], configuration: inout VehicleConfiguration) throws -> Data {
        let reading = bytes[0] == 0
        guard bytes.count == (reading ? 3 : 9) else { throw ProtocolFailure.invalidLength }
        let index = Int(bytes[2])
        guard configuration.maps.indices.contains(index), (0..<5).contains(index) else { throw ProtocolFailure.unsupported }
        if !reading {
            guard bytes[3] == 1, Int(bytes[8]) == index + 1 else { throw ProtocolFailure.unsupported }
            let torque = signed(bytes, at: 4), regeneration = signed(bytes, at: 6)
            guard (0...100).contains(torque), (-100...100).contains(regeneration) else { throw ProtocolFailure.unsupported }
            configuration.maps[index].torque = torque
            configuration.maps[index].regeneration = regeneration
            configuration.maps[index].curve = index + 1
            return Data([1, 0, 0])
        }
        let map = configuration.maps[index]
        return Data([0, 0, 0, UInt8(index)]) + WireBytes.u16(map.torque)
            + WireBytes.u16(map.regeneration) + Data([UInt8(map.curve)])
    }

    private func charger(_ bytes: [UInt8], configuration: inout VehicleConfiguration) throws -> Data {
        let reading = bytes[0] == 0
        guard bytes.count == (reading ? 2 : 13) else { throw ProtocolFailure.invalidLength }
        if !reading {
            guard bytes[2] == 1 else { throw ProtocolFailure.unsupported }
            let power = unsigned(bytes, at: 5), target = unsigned(bytes, at: 7)
            guard (300...3300).contains(power), (10...1000).contains(target), target.isMultiple(of: 10) else {
                throw ProtocolFailure.unsupported
            }
            configuration.charger.current = unsigned(bytes, at: 3)
            configuration.charger.power = power
            configuration.charger.target = target
            configuration.charger.standardMaximum = unsigned(bytes, at: 9)
            configuration.charger.backpackMaximum = unsigned(bytes, at: 11)
            return Data([1, 4, 0])
        }
        let value = configuration.charger
        return [value.current, value.power, value.target, value.minimumCurrent, value.startTime,
                value.rampTime, value.standardMaximum, value.backpackMaximum]
            .reduce(into: Data([0, 4, 0])) { $0.append(WireBytes.u16($1)) }
    }

    private func traction(_ bytes: [UInt8], configuration: inout VehicleConfiguration) throws -> Data {
        let reading = bytes[0] == 0
        guard bytes.count == (reading ? 3 : 9) else { throw ProtocolFailure.invalidLength }
        let index = Int(bytes[reading ? 2 : 3])
        guard configuration.traction.indices.contains(index), (0..<5).contains(index) else {
            throw ProtocolFailure.unsupported
        }
        if !reading {
            guard bytes[2] == 1, bytes[4] == 15 else { throw ProtocolFailure.unsupported }
            let power = signed(bytes, at: 5), braking = signed(bytes, at: 7)
            guard (-1000...1000).contains(power), (-1000...1000).contains(braking) else {
                throw ProtocolFailure.unsupported
            }
            configuration.traction[index].power = power
            configuration.traction[index].braking = braking
            return Data([1, 8, 0])
        }
        let value = configuration.traction[index]
        return Data([0, 8, 0, UInt8(index)]) + WireBytes.u16(value.power) + WireBytes.u16(value.braking)
    }

    private func lock(_ bytes: [UInt8], configuration: inout VehicleConfiguration) throws -> Data {
        let reading = bytes[0] == 0
        guard bytes.count == (reading ? 2 : 7) else { throw ProtocolFailure.invalidLength }
        if !reading {
            guard bytes[2] == 0x83, bytes[3] <= 1, bytes[4] == 1 else { throw ProtocolFailure.unsupported }
            configuration.lock.isLocked = bytes[3] == 1
            configuration.lock.type = bytes[4]
            configuration.lock.timeout = signed(bytes, at: 5)
            return Data([1, 5, 0])
        }
        let value = configuration.lock
        return Data([0, 5, 0, value.isLocked ? 1 : 0, value.type]) + WireBytes.u16(value.timeout)
    }

    private func curve(_ bytes: [UInt8], configuration: inout VehicleConfiguration) throws -> Data {
        let reading = bytes[0] == 0
        guard bytes.count == (reading ? 3 : 68) else { throw ProtocolFailure.invalidLength }
        let selector = Int(bytes[reading ? 2 : 3])
        let index = selector - 1
        guard (1...5).contains(selector), configuration.curves.indices.contains(index) else { throw ProtocolFailure.unsupported }
        if !reading {
            guard bytes[2] == 1, Array(bytes[4..<8]) == [255,127,255,127] else { throw ProtocolFailure.unsupported }
            let power = (0..<15).map { unsigned(bytes, at: 8 + $0 * 2) }
            let regeneration = (0..<15).map { unsigned(bytes, at: 38 + $0 * 2) }
            guard power.allSatisfy({ (0...1000).contains($0) }), power.contains(where: { $0 > 0 }),
                  regeneration.allSatisfy({ (0...1000).contains($0) }) else { throw ProtocolFailure.unsupported }
            configuration.curves[index].power = power
            configuration.curves[index].regeneration = regeneration
            return Data([1, 1, 0])
        }
        let value = configuration.curves[index]
        // Read responses interleave the series; write requests store each complete series consecutively.
        return zip(value.power, value.regeneration).reduce(into: Data([0,1,0,UInt8(selector)])) {
            $0.append(WireBytes.u16($1.0))
            $0.append(WireBytes.u16($1.1))
        }
    }

    private func unsigned(_ bytes: [UInt8], at index: Int) -> Int {
        Int(bytes[index]) | (Int(bytes[index + 1]) << 8)
    }
    private func signed(_ bytes: [UInt8], at index: Int) -> Int {
        Int(Int16(bitPattern: UInt16(unsigned(bytes, at: index))))
    }
}
