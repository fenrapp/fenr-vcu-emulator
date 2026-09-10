import Foundation
import EmulatorDomain
import ProtocolCore
import ProtocolEngine

public struct FailureMapper {
    public init() {}
    public func map(_ snapshot: EmulatorSnapshot) -> FailureViewState {
        let fault = snapshot.fault
        return .init(selected: fault.scenario.rawValue,
                     choices: FaultScenario.allCases.map { item in
                         .init(id: item.rawValue, title: title(item),
                               available: !snapshot.running || (!FaultSettings(scenario: item).requiresStoppedServer && !fault.requiresStoppedServer))
                     }, description: detail(fault.scenario), running: snapshot.running,
                     requiresStop: fault.requiresStoppedServer, delay: fault.delay,
                     targets: CharacteristicID.allCases.filter(\.isTelemetry).map {
                         .init(id: $0.rawValue, title: telemetryTitle($0) + String(format: " (%04X)", $0.rawValue), enabled: fault.affected.contains($0))
                     })
    }
    private func telemetryTitle(_ id: CharacteristicID) -> String {
        switch id {
        case .battery: failureText("Battery")
        case .status: failureText("Status and signals")
        case .speed: failureText("Speed")
        case .map: failureText("Active map")
        case .totals: failureText("Odometer")
        case .brake: failureText("Brake")
        case .charger: failureText("Charger")
        case .batteryTemperatures: failureText("Battery temperature")
        case .inverterTemperatures: failureText("Inverter temperature")
        default: failureText("Telemetry")
        }
    }
    private func title(_ fault: FaultScenario) -> String {
        switch fault {
        case .none: failureText("No fault")
        case .rejectedAuthentication: failureText("Reject authentication")
        case .delayedResponses: failureText("Delay application responses")
        case .missingResponses: failureText("Silence application responses")
        case .staleTelemetry: failureText("Freeze telemetry")
        case .malformedTelemetry: failureText("Malformed speed payload")
        case .unsupportedFirmware: failureText("Unsupported firmware")
        case .unsupportedCapabilities: failureText("Unsupported curve capability")
        case .unappliedWrites: failureText("Accept writes without applying")
        case .failedTractionRead: failureText("Fail initial traction read")
        }
    }
    private func detail(_ fault: FaultScenario) -> String {
        switch fault {
        case .none: failureText("Normal protocol behavior. All supported commands are available.")
        case .rejectedAuthentication: failureText("Reject the V2 response. Stop Bluetooth before changing this profile.")
        case .delayedResponses: failureText("Hold configuration replies for the selected delay. ATT acknowledgments remain separate.")
        case .missingResponses: failureText("Suppress application replies and publish configuration without reads. Restart required; the radio link remains present.")
        case .staleTelemetry: failureText("Keep the selected datasets at their current values while the simulated state continues changing.")
        case .malformedTelemetry: failureText("Send a one-byte speed payload so the client can reject it.")
        case .unsupportedFirmware: failureText("Report an incompatible firmware profile and reject configuration commands. Restart required.")
        case .unsupportedCapabilities: failureText("Reject advanced curve operations. Restart required.")
        case .unappliedWrites: failureText("Acknowledge supported writes but retain the previous configuration. Fresh reads expose the unchanged values.")
        case .failedTractionRead: failureText("Reject traction reads until an explicit traction write succeeds in this session.")
        }
    }
}
