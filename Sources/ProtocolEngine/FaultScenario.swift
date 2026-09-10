import Foundation

public enum FaultScenario: String, CaseIterable, Sendable {
    case none
    case rejectedAuthentication
    case delayedResponses
    case missingResponses
    case staleTelemetry
    case malformedTelemetry
    case unsupportedFirmware
    case unsupportedCapabilities
    case unappliedWrites
    case failedTractionRead
}
