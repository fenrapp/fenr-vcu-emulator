import BLEPeripheral
import ProtocolCore
import ProtocolEngine
import VehicleSimulation

@MainActor
enum EmulatorComposition {
    static func make() -> EmulatorViewModel {
        // This fixed synthetic VIN is validated by the upstream identity utility.
        let identity = try! EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
        let clock = MonotonicSessionClock()
        let session = SessionEngine(identity: identity,
                                    verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                    nonceGenerator: SystemNonceGenerator(), clock: clock)
        let engine = EmulatorEngine(session: session, state: VehicleState(), encoder: TelemetryEncoder(), simulator: ScenarioSimulator(), configurationHandler: ConfigurationHandler(), clock: clock)
        let activity = ActivityStore(state: EmulatorViewState(), mapper: PeripheralEventMapper())
        let server = PeripheralServer(engine: engine, queue: NotificationQueue(capacity: 128), clock: clock,
                                      event: { [activity] in activity.receive($0) })
        return EmulatorViewModel(activity: activity, engine: engine, server: server, tickWaiter: SystemTickWaiter(), scenarioMapper: ScenarioPresentationMapper())
    }
}
