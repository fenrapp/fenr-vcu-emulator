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
    var requireEncryption = true
    private let engine: EmulatorEngine
    private let server: PeripheralServer
    private let tickWaiter: any TickWaiting
    private var ticker: Task<Void, Never>?

    init(activity: ActivityStore, engine: EmulatorEngine, server: PeripheralServer, tickWaiter: any TickWaiting) {
        self.activity = activity
        self.engine = engine
        self.server = server
        self.tickWaiter = tickWaiter
        self.identityName = engine.session.identity.vin
        self.pairingPIN = engine.session.identity.pin
        self.batteryPercent = Double(engine.state.batteryPercent)
        self.speedKmh = engine.state.speedKmh
        self.charging = engine.state.isCharging
    }

    isolated deinit { ticker?.cancel() }

    func start() {
        ticker?.cancel()
        server.start(security: requireEncryption ? .encrypted : .applicationOnly)
        ticker = Task { [weak self, tickWaiter] in
            while !Task.isCancelled {
                do { try await tickWaiter.wait() } catch { return }
                guard !Task.isCancelled, let self, self.activity.state.running else { return }
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
    private func updateTelemetry() {
        engine.setState(VehicleState(batteryPercent: Int(batteryPercent), speedKmh: speedKmh,
                                     mapIndex: engine.state.mapIndex, isCharging: charging,
                                     odometerMeters: engine.state.odometerMeters))
        server.publishTelemetry()
    }
}
