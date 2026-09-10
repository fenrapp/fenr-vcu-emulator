import Foundation
import ProtocolCore
import ProtocolEngine

public struct FaultSettings: Equatable, Codable, Sendable {
    public var scenario: FaultScenario
    public var delay: Double
    public var affected: Set<CharacteristicID>
    public init(scenario: FaultScenario = .none, delay: Double = 6,
                affected: Set<CharacteristicID> = Set(CharacteristicID.allCases.filter(\.isTelemetry))) {
        self.scenario = scenario; self.delay = delay; self.affected = affected
    }
    public var requiresStoppedServer: Bool {
        [.rejectedAuthentication, .missingResponses, .unsupportedFirmware, .unsupportedCapabilities].contains(scenario)
    }
    public var isValid: Bool { delay.isFinite && (0...30).contains(delay) && affected.allSatisfy(\.isTelemetry) }
}
