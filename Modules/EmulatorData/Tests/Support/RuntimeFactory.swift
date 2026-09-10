import Foundation
import EmulatorDomain
import ProtocolCore
import ProtocolEngine
import VehicleSimulation
@testable import EmulatorData

@MainActor enum RuntimeFactory {
    static func make() throws -> (LiveEmulatorRepository, EmulatorEngine, RuntimeServer, MemoryPresets) {
        let clock = MonotonicSessionClock()
        let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
        let session = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                    nonceGenerator: SystemNonceGenerator(), clock: clock)
        let validator = ConfigurationValidator()
        let engine = EmulatorEngine(session: session, state: VehicleState(), encoder: TelemetryEncoder(), simulator: ScenarioSimulator(),
                                    configurationHandler: ConfigurationHandler(validator: validator), clock: clock)
        let server = RuntimeServer(), presets = MemoryPresets()
        let channel = AsyncStream<TransportEvent>.makeStream()
        let runtime = LiveEmulatorRepository(engine: engine, server: server, events: channel.stream, waiter: LongTick(),
                                             presets: presets, validator: validator, reducer: TelemetryReducer(), now: Date.init, makeID: UUID.init)
        runtime.activate()
        return (runtime, engine, server, presets)
    }
}
