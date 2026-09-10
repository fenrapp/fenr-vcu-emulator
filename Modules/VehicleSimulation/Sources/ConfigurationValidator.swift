public enum ConfigurationValidationError: Error, Equatable, Sendable { case invalidValues }

public struct ConfigurationValidator: Sendable {
    public init() {}
    public func validate(_ value: VehicleConfiguration) throws {
        let charger = value.charger
        guard value.maps.count == 5, value.traction.count == 5, value.curves.count == 5,
              (300...3300).contains(charger.power), (10...1000).contains(charger.target),
              charger.target.isMultiple(of: 10), value.lock.type == 1,
              (-32768...32767).contains(value.lock.timeout),
              [charger.current, charger.minimumCurrent, charger.startTime, charger.rampTime,
               charger.standardMaximum, charger.backpackMaximum].allSatisfy({ (0...65535).contains($0) })
        else { throw ConfigurationValidationError.invalidValues }
        for index in 0..<5 {
            let map = value.maps[index], traction = value.traction[index], curve = value.curves[index]
            guard (0...100).contains(map.torque), (-100...100).contains(map.regeneration),
                  map.curve == 0 || map.curve == index + 1,
                  (-1000...1000).contains(traction.power), (-1000...1000).contains(traction.braking),
                  curve.power.count == 15, curve.regeneration.count == 15,
                  curve.power.allSatisfy({ (0...1000).contains($0) }), curve.power.contains(where: { $0 > 0 }),
                  curve.regeneration.allSatisfy({ (0...1000).contains($0) })
            else { throw ConfigurationValidationError.invalidValues }
        }
    }
}
