import Foundation
import VehicleSimulation

struct ConfigurationPresentationMapper {
    func map(_ configuration: VehicleConfiguration) -> ConfigurationViewState {
        ConfigurationViewState(
            chargingPower: configuration.charger.power.formatted(),
            chargeTarget: (Double(configuration.charger.target) / 10).formatted(),
            lockStatus: configuration.lock.isLocked ? String(localized: "Locked") : String(localized: "Unlocked"),
            maps: configuration.maps.indices.map { index in
                let map = configuration.maps[index]
                let traction = configuration.traction[index]
                let curve = configuration.curves[index]
                return ConfigurationViewState.MapRow(
                    id: index, title: String(localized: "Map \(index + 1)"),
                    torque: map.torque.formatted(), regeneration: map.regeneration.formatted(),
                    powerTraction: (Double(traction.power) / 10).formatted(),
                    brakingTraction: (Double(traction.braking) / 10).formatted(),
                    powerCurve: curve.power.map { String($0) }.joined(separator: ", "),
                    regenerationCurve: curve.regeneration.map { String($0) }.joined(separator: ", ")
                )
            }
        )
    }
}
