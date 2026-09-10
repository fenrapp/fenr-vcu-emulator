import Foundation
import EmulatorDomain

struct WorkspaceSessionMapper {
    func map(_ snapshot: EmulatorSnapshot) -> WorkspaceSessionState {
        let transport: String = switch snapshot.transport {
        case .stopped: String(localized: "Stopped")
        case .starting: String(localized: "Starting Bluetooth")
        case .advertising: String(localized: "Advertising")
        case .unavailable: String(localized: "Bluetooth unavailable")
        case .unauthorized: String(localized: "Bluetooth permission required")
        case .failed: String(localized: "Bluetooth error")
        }
        let authentication: String = switch snapshot.authentication {
        case .idle: String(localized: "No authenticated session")
        case .challenged: String(localized: "Waiting for V2 response")
        case .authenticated: String(localized: "V2 authenticated")
        }
        let scenario: String = switch snapshot.scenario {
        case .parked: String(localized: "Parked")
        case .riding: String(localized: "Riding")
        case .charging: String(localized: "Charging")
        case .partialTelemetry: String(localized: "Partial telemetry")
        }
        return .init(transport: transport, authentication: authentication, scenario: scenario,
                     latestActivity: snapshot.activity.last?.detail ?? String(localized: "Ready when you are."),
                     running: snapshot.running, hasFault: snapshot.fault.scenario != .none)
    }
}
