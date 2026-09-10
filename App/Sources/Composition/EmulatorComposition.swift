import AppKit
import Foundation
import EmulatorDomain
import EmulatorData
import BLEPeripheral
import ProtocolCore
import ProtocolEngine
import VehicleSimulation
import SimulationFeature
import ConfigurationFeature
import FailuresFeature
import ActivityFeature

@MainActor enum EmulatorComposition {
    static func make() -> WorkspaceViewModel {
        let identity = try! EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
        let clock = MonotonicSessionClock(), validator = ConfigurationValidator()
        let session = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                    nonceGenerator: SystemNonceGenerator(), clock: clock)
        let engine = EmulatorEngine(session: session, state: VehicleState(), encoder: TelemetryEncoder(), simulator: ScenarioSimulator(),
                                    configurationHandler: ConfigurationHandler(validator: validator), clock: clock)
        let channel = AsyncStream<TransportEvent>.makeStream(bufferingPolicy: .bufferingNewest(256))
        let server = PeripheralServer(engine: engine, queue: NotificationQueue(capacity: 128), clock: clock,
                                      event: { channel.continuation.yield(TransportEvent(generation: session.generation, event: $0)) })
        let manager = FileManager.default
        let directory = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("FENRVCUEmulator", isDirectory: true)
        let store = LocalPresetStore(directory: directory, fileManager: manager, encoder: JSONEncoder(), decoder: JSONDecoder(), validator: validator)
        let runtime = LiveEmulatorRepository(engine: engine, server: server, events: channel.stream, waiter: SystemTickWaiter(),
                                             presets: store, validator: validator, reducer: TelemetryReducer(), now: Date.init, makeID: UUID.init)
        let useCases = EmulatorUseCases(repository: runtime)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.2.0"
        return WorkspaceViewModel(useCases: useCases, mapper: WorkspaceSessionMapper(),
                                  simulation: SimulationViewModel(useCases: useCases, mapper: SimulationMapper()),
                                  configuration: ConfigurationEditorViewModel(useCases: useCases, mapper: ConfigurationEditorMapper()),
                                  failures: FailureViewModel(useCases: useCases, mapper: FailureMapper()),
                                  activity: ActivityViewModel(useCases: useCases, mapper: ActivityMapper(), clipboard: SystemClipboard(pasteboard: .general), version: version),
                                  identity: identity.vin, pin: identity.pin,
                                  activate: { runtime.activate() }, shutdown: { runtime.shutdown() })
    }
}
