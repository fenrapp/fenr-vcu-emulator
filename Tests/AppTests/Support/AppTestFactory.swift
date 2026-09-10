import BLEPeripheral
import ProtocolCore
import ProtocolEngine
import VehicleSimulation
@testable import FENRVCUEmulator

@MainActor
enum AppTestFactory {
    static func make() throws -> (EmulatorViewModel, RecordingPeripheralServer) {
        let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
        let clock = MonotonicSessionClock()
        let session = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                    nonceGenerator: SystemNonceGenerator(), clock: clock)
        let engine = EmulatorEngine(session: session, state: VehicleState(), encoder: TelemetryEncoder(),
                                    simulator: ScenarioSimulator(), configurationHandler: ConfigurationHandler(validator: ConfigurationValidator()), clock: clock)
        let activity = ActivityStore(state: EmulatorViewState(), mapper: PeripheralEventMapper())
        let server = RecordingPeripheralServer(activity: activity)
        return (EmulatorViewModel(activity: activity, engine: engine, server: server, tickWaiter: FastTickWaiter(),
                                  scenarioMapper: ScenarioPresentationMapper(), faultMapper: FaultPresentationMapper(),
                                  configurationMapper: ConfigurationPresentationMapper()), server)
    }
}
