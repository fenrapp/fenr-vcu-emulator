import Foundation
import ProtocolEngine

struct FaultPresentationMapper {
    func choices() -> [ScenarioChoice] {
        FaultScenario.allCases.map { fault in
            let title: String
            switch fault {
            case .none: title = String(localized: "Normal operation")
            case .rejectedAuthentication: title = String(localized: "Reject V2 authentication")
            case .delayedResponses: title = String(localized: "Delay configuration responses by 6 seconds")
            case .missingResponses: title = String(localized: "Never send configuration responses")
            case .staleTelemetry: title = String(localized: "Freeze telemetry values")
            case .malformedTelemetry: title = String(localized: "Send an incomplete speed packet")
            case .unsupportedFirmware: title = String(localized: "Report unsupported firmware")
            case .unsupportedCapabilities: title = String(localized: "Reject advanced curve records")
            case .unappliedWrites: title = String(localized: "Acknowledge writes without applying them")
            case .failedTractionRead: title = String(localized: "Fail traction reads; accept explicit writes")
            }
            return ScenarioChoice(id: fault.rawValue, title: title)
        }
    }
}
