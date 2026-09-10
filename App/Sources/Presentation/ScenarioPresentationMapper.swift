import Foundation
import VehicleSimulation

struct ScenarioPresentationMapper {
    func choices() -> [ScenarioChoice] {
        SimulationScenario.allCases.map { scenario in
            let title: String
            switch scenario {
            case .parked: title = String(localized: "Parked")
            case .riding: title = String(localized: "Riding")
            case .charging: title = String(localized: "Charging")
            case .partialTelemetry: title = String(localized: "Partial telemetry")
            }
            return ScenarioChoice(id: scenario.rawValue, title: title)
        }
    }
}
