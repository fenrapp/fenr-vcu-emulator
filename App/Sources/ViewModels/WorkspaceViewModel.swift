import Foundation
import Observation
import EmulatorDomain
import SimulationFeature
import ConfigurationFeature
import FailuresFeature
import ActivityFeature

@MainActor @Observable final class WorkspaceViewModel {
    private(set) var session: WorkspaceSessionState
    private(set) var encrypted = true
    let simulation: SimulationViewModel
    let configuration: ConfigurationEditorViewModel
    let failures: FailureViewModel
    let activity: ActivityViewModel
    let identity: String
    let pin: String
    private let useCases: EmulatorUseCases
    private let mapper: WorkspaceSessionMapper
    private let activate: () -> Void
    private let shutdown: () -> Void
    init(useCases: EmulatorUseCases, mapper: WorkspaceSessionMapper, simulation: SimulationViewModel,
         configuration: ConfigurationEditorViewModel, failures: FailureViewModel, activity: ActivityViewModel,
         identity: String, pin: String, activate: @escaping () -> Void, shutdown: @escaping () -> Void) {
        self.useCases = useCases; self.mapper = mapper; self.simulation = simulation; self.configuration = configuration
        self.failures = failures; self.activity = activity; self.identity = identity; self.pin = pin
        self.activate = activate; self.shutdown = shutdown; self.session = mapper.map(useCases.current)
    }
    func observe() async {
        activate()
        for await snapshot in useCases.observe() { guard !Task.isCancelled else { return }; session = mapper.map(snapshot) }
    }
    func toggleServer() { try? useCases.execute(session.running ? .stop : .start(encrypted: encrypted)) }
    func setEncryption(_ value: Bool) { if !session.running { encrypted = value } }
    func close() { shutdown() }
}
