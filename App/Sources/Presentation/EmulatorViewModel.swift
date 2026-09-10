import Foundation
import Observation
import BLEPeripheral
import ProtocolCore
import ProtocolEngine
import VehicleSimulation

@MainActor @Observable
final class EmulatorViewModel {
    let activity: ActivityStore
    let identityName: String
    let pairingPIN: String
    private(set) var batteryPercent: Double
    private(set) var speedKmh: Double
    private(set) var charging: Bool
    private(set) var temperatureCelsius: Double
    private(set) var mapIndex: Int
    private(set) var scenarioID: String = "parked"
    let scenarioChoices: [ScenarioChoice]
    let faultChoices: [ScenarioChoice]
    private(set) var faultID: String = "none"
    private(set) var configurationState: ConfigurationViewState
    private let configurationMapper: ConfigurationPresentationMapper
    var requireEncryption = true
    private let engine: EmulatorEngine
    private let server: any PeripheralServing
    private let tickWaiter: any TickWaiting
    private var ticker: Task<Void, Never>?

    init(activity: ActivityStore, engine: EmulatorEngine, server: any PeripheralServing, tickWaiter: any TickWaiting, scenarioMapper: ScenarioPresentationMapper, faultMapper: FaultPresentationMapper, configurationMapper: ConfigurationPresentationMapper) {
        self.activity = activity
        self.engine = engine
        self.server = server
        self.tickWaiter = tickWaiter
        self.identityName = engine.session.identity.vin
        self.pairingPIN = engine.session.identity.pin
        self.batteryPercent = Double(engine.state.batteryPercent)
        self.speedKmh = engine.state.speedKmh
        self.charging = engine.state.isCharging
        self.temperatureCelsius = engine.state.temperatureCelsius
        self.mapIndex = engine.state.mapIndex
        self.scenarioChoices = scenarioMapper.choices()
        self.faultChoices = faultMapper.choices()
        self.configurationMapper = configurationMapper
        self.configurationState = configurationMapper.map(engine.state.configuration)
    }

    isolated deinit { ticker?.cancel(); server.stop() }

    func start() {
        ticker?.cancel()
        server.start(security: requireEncryption ? .encrypted : .applicationOnly)
        ticker = Task { [weak self, tickWaiter] in
            while !Task.isCancelled {
                do { try await tickWaiter.wait() } catch { return }
                guard !Task.isCancelled, let self, self.activity.state.running else { return }
                self.engine.advance(seconds: 1)
                self.refreshPresentation()
                self.server.publishTelemetry()
            }
        }
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        server.stop()
    }

    func setBattery(_ value: Double) {
        batteryPercent = min(100, max(0, value.rounded()))
        updateTelemetry()
    }
    func setSpeed(_ value: Double) {
        speedKmh = min(150, max(0, value.rounded()))
        if speedKmh > 0 { charging = false }
        updateTelemetry()
    }
    func setCharging(_ value: Bool) {
        charging = value
        if charging { speedKmh = 0 }
        updateTelemetry()
    }
    func selectFault(_ id: String) {
        guard !activity.state.running, let fault = FaultScenario(rawValue: id) else { return }
        faultID = id
        engine.setFault(fault)
    }
    func selectScenario(_ id: String) {
        guard let scenario = SimulationScenario(rawValue: id) else { return }
        scenarioID = id
        engine.resetScenario(scenario)
        refreshPresentation()
        server.publishTelemetry()
    }
    func resetScenario() { selectScenario(scenarioID) }
    func setTemperature(_ value: Double) {
        temperatureCelsius = min(80, max(-20, value.rounded()))
        updateTelemetry()
    }
    func setMap(_ index: Int) {
        mapIndex = min(4, max(0, index))
        updateTelemetry()
    }
    private func refreshPresentation() {
        configurationState = configurationMapper.map(engine.state.configuration)
        batteryPercent = Double(engine.state.batteryPercent)
        speedKmh = engine.state.speedKmh
        charging = engine.state.isCharging
        temperatureCelsius = engine.state.temperatureCelsius
        mapIndex = engine.state.mapIndex
    }
    private func updateTelemetry() {
        var state = engine.state
        state.batteryPercent = Int(batteryPercent)
        state.speedKmh = speedKmh
        state.mapIndex = mapIndex
        state.isCharging = charging
        state.temperatureCelsius = temperatureCelsius
        engine.setState(state)
        server.publishTelemetry()
    }
}
