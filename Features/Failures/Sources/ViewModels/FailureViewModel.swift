import Foundation
import Observation
import EmulatorDomain
import ProtocolCore
import ProtocolEngine

@MainActor @Observable public final class FailureViewModel {
    public private(set) var state: FailureViewState
    public private(set) var message: String?
    private let useCases: EmulatorUseCases
    private let mapper: FailureMapper
    public init(useCases: EmulatorUseCases, mapper: FailureMapper) {
        self.useCases = useCases; self.mapper = mapper; self.state = mapper.map(useCases.current)
    }
    public func observe() async {
        for await value in useCases.observe() { guard !Task.isCancelled else { return }; state = mapper.map(value) }
    }
    public func select(_ id: String) {
        guard let scenario = FaultScenario(rawValue: id) else { return }
        var settings = useCases.current.fault; settings.scenario = scenario; apply(settings)
    }
    public func setDelay(_ delay: Double) { var settings = useCases.current.fault; settings.delay = delay; apply(settings) }
    public func setTarget(_ id: UInt16, enabled: Bool) {
        guard let target = CharacteristicID(rawValue: id), target.isTelemetry else { return }
        var settings = useCases.current.fault
        if enabled { settings.affected.insert(target) } else { settings.affected.remove(target) }
        apply(settings)
    }
    private func apply(_ settings: FaultSettings) {
        do { try useCases.execute(.fault(settings)); state = mapper.map(useCases.current); message = nil }
        catch { message = failureText("Stop Bluetooth before changing this profile, and use a delay between 0 and 30 seconds.") }
    }
}
