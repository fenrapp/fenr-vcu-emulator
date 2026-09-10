import Foundation

public enum SimulationScenario: String, CaseIterable, Sendable {
    case parked, riding, charging, partialTelemetry
}

public struct ScenarioSimulator: Sendable {
    public init() {}

    public func initialState(for scenario: SimulationScenario) -> VehicleState {
        switch scenario {
        case .parked: VehicleState()
        case .riding: VehicleState(speedKmh: 35, temperatureCelsius: 36)
        case .charging: VehicleState(batteryPercent: 55, isCharging: true, temperatureCelsius: 28)
        case .partialTelemetry: VehicleState(partialTelemetry: true)
        }
    }

    public func advance(_ state: VehicleState, seconds: TimeInterval) -> VehicleState {
        guard seconds.isFinite, seconds > 0 else { return state }
        var next = state
        let duration = min(seconds, 5)
        next.odometerMeters += next.speedKmh / 3.6 * duration
        next.simulationSeconds += duration
        // Deliberately accelerated battery behavior: one percentage point per simulated minute.
        let steps = Int(next.simulationSeconds / 60) - Int(state.simulationSeconds / 60)
        if next.isCharging {
            next.speedKmh = 0
            let target = next.configuration.charger.target / 10
            next.batteryPercent = min(max(next.batteryPercent, target), next.batteryPercent + steps)
            if next.batteryPercent >= target { next.isCharging = false }
        } else if next.speedKmh > 0 {
            next.batteryPercent = max(0, next.batteryPercent - steps)
            if next.batteryPercent == 0 { next.speedKmh = 0 }
        }
        return next
    }
}
