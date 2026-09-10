import Foundation
import EmulatorDomain

public struct SimulationMapper {
    public init() {}
    public func map(_ snapshot: EmulatorSnapshot) -> SimulationViewState {
        let v = snapshot.vehicle
        var controls: [SimulationNumber] = [
            .init(id: "battery", title: simulationText("Battery"), value: Double(v.batteryPercent), range: 0...100, step: 1, unit: "%"),
            .init(id: "health", title: simulationText("Battery health"), value: Double(v.batteryHealthPercent), range: 0...100, step: 1, unit: "%"),
            .init(id: "voltage", title: simulationText("Battery voltage"), value: v.dcBusVolts, range: 0...500, step: 0.1, unit: "V"),
            .init(id: "temperature", title: simulationText("Temperature"), value: v.temperatureCelsius, range: -20...80, step: 1, unit: "C"),
            .init(id: "odometer", title: simulationText("Odometer"), value: v.odometerMeters / 1000, range: 0...100000, step: 0.1, unit: "km"),
            .init(id: "map", title: simulationText("Active map"), value: Double(v.mapIndex + 1), range: 1...5, step: 1, unit: "")
        ]
        if snapshot.scenario == .riding {
            controls.insert(.init(id: "speed", title: simulationText("Speed"), value: v.speedKmh, range: 0...150, step: 1, unit: "km/h"), at: 0)
        }
        let signals = v.signals
        var toggles: [SimulationToggle] = [
            .init(id: "power", title: simulationText("Powered on"), enabled: signals.poweredOn),
            .init(id: "left", title: simulationText("Left indicator"), enabled: signals.leftIndicator),
            .init(id: "right", title: simulationText("Right indicator"), enabled: signals.rightIndicator),
            .init(id: "hazards", title: simulationText("Hazard lights"), enabled: signals.leftIndicator && signals.rightIndicator),
            .init(id: "highBeam", title: simulationText("High beam"), enabled: signals.highBeam),
            .init(id: "brake", title: simulationText("Brake signal"), enabled: signals.brake),
            .init(id: "checkEngine", title: simulationText("Check engine"), enabled: signals.checkEngine)
        ]
        if snapshot.scenario == .riding { toggles.insert(.init(id: "gear", title: simulationText("In gear"), enabled: signals.inGear), at: 1) }
        if snapshot.scenario == .charging {
            controls += [
                .init(id: "requestedCurrent", title: simulationText("Requested current"), value: v.charging.requestedCurrent, range: 0...100, step: 0.1, unit: "A"),
                .init(id: "reportedCurrent", title: simulationText("Delivered current"), value: v.charging.reportedCurrent, range: 0...100, step: 0.1, unit: "A"),
                .init(id: "targetCellVoltage", title: simulationText("Target cell voltage"), value: v.charging.targetCellVolts, range: 0...6.5, step: 0.01, unit: "V"),
                .init(id: "chargePower", title: simulationText("Charge power limit"), value: Double(v.configuration.charger.power), range: 300...3300, step: 100, unit: "W"),
                .init(id: "chargeTarget", title: simulationText("Charge target"), value: Double(v.configuration.charger.target / 10), range: 1...100, step: 1, unit: "%"),
                .init(id: "chargerType", title: simulationText("Charger type (0 standard, 2 fast, 3 backpack)"), value: Double(v.charging.type), range: 0...3, step: 1, unit: ""),
                .init(id: "chargerStatus", title: simulationText("Raw charger status (diagnostic only)"), value: Double(v.charging.status), range: 0...255, step: 1, unit: "")
            ]
            toggles.insert(.init(id: "charging", title: simulationText("Charging enabled"), enabled: v.isCharging), at: 0)
            toggles.insert(.init(id: "chargerConnected", title: simulationText("Charger connected"), enabled: v.charging.connected), at: 0)
        }
        let title: String = switch snapshot.scenario {
        case .parked: simulationText("Parked")
        case .riding: simulationText("Riding")
        case .charging: simulationText("Charging")
        case .partialTelemetry: simulationText("Partial telemetry")
        }
        return .init(scenarioID: snapshot.scenario.rawValue, scenarioTitle: title,
                     battery: "\(v.batteryPercent)%", speed: "\(v.speedKmh.formatted(.number.precision(.fractionLength(0)))) km/h",
                     deliveredPower: "\(((v.isCharging ? v.charging.reportedCurrent : 0) * v.dcBusVolts).formatted(.number.precision(.fractionLength(0)))) W",
                     requestedPower: "\((v.charging.requestedCurrent * v.dcBusVolts).formatted(.number.precision(.fractionLength(0)))) W",
                     controls: controls, signals: toggles, charging: snapshot.scenario == .charging,
                     partial: snapshot.scenario == .partialTelemetry, running: snapshot.running,
                     presets: snapshot.presets.map { .init(id: $0.id, title: $0.name) })
    }
}
