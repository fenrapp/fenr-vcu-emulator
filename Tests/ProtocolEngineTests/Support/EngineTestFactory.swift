import Foundation
import ProtocolCore
import ProtocolEngine
import VehicleSimulation

@MainActor
enum EngineTestFactory {
    static func make(clock: ManualSessionClock = ManualSessionClock()) throws -> EmulatorEngine {
        let identity = try EmulatedIdentity(vin: "FENRTEST000000001", pairingDate: "19700101")
        let session = SessionEngine(identity: identity, verifier: AuthenticationVerifier(builder: StarkAuthenticationPayloadBuilder()),
                                    nonceGenerator: FixedNonceGenerator(), clock: clock)
        return EmulatorEngine(session: session, state: VehicleState(), encoder: TelemetryEncoder(),
                              simulator: ScenarioSimulator(), configurationHandler: ConfigurationHandler(), clock: clock)
    }
    static func authenticate(_ engine: EmulatorEngine, central: UUID) throws {
        let nonce = try engine.read(central: central, characteristic: .security, offset: 0)
        _ = try engine.subscribe(central: central, characteristic: .security)
        let identity = engine.session.identity
        let response = try StarkAuthenticationPayloadBuilder().buildVersionTwo(vin: identity.vin, pairingDate: identity.pairingDate, nonce: nonce)
        _ = try engine.write(central: central, characteristic: .security, offset: 0, value: response)
    }
}
