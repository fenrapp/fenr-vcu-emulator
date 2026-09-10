import Foundation
import EmulatorDomain
import BLEPeripheral
import ProtocolCore
import ProtocolEngine
import VehicleSimulation

@MainActor public final class LiveEmulatorRepository: EmulatorRepository {
    public private(set) var snapshot: EmulatorSnapshot
    private let engine: EmulatorEngine
    private let server: any PeripheralServing
    private let events: AsyncStream<TransportEvent>
    private let waiter: any TickWaiting
    private let presets: any PresetStoring
    private let validator: ConfigurationValidator
    private let reducer: TelemetryReducer
    private let now: () -> Date
    private let makeID: () -> UUID
    private var ticker: Task<Void, Never>?
    private var observer: Task<Void, Never>?
    private var subscribers: [UUID: AsyncStream<EmulatorSnapshot>.Continuation] = [:]
    private var ticks = 0
    private var storageLoaded = false

    public init(engine: EmulatorEngine, server: any PeripheralServing, events: AsyncStream<TransportEvent>,
                waiter: any TickWaiting, presets: any PresetStoring, validator: ConfigurationValidator,
                reducer: TelemetryReducer, now: @escaping () -> Date, makeID: @escaping () -> UUID) {
        self.engine = engine; self.server = server; self.events = events; self.waiter = waiter
        self.presets = presets; self.validator = validator; self.reducer = reducer
        self.now = now; self.makeID = makeID
        self.snapshot = EmulatorSnapshot(vehicle: engine.state, fault: FaultSettings())
    }
    isolated deinit { ticker?.cancel(); observer?.cancel(); server.stop(); for value in subscribers.values { value.finish() } }

    public func activate() {
        guard observer == nil else { return }
        do { snapshot.presets = try presets.load(); storageLoaded = true }
        catch { record(.preset, .error, .system, "Preset storage could not be loaded; existing files are unchanged") }
        let events = events
        observer = Task { [weak self] in
            for await event in events {
                guard !Task.isCancelled else { return }
                self?.receive(event)
            }
        }
        publish()
    }
    public func shutdown() {
        stop(); observer?.cancel(); observer = nil
        for value in subscribers.values { value.finish() }
        subscribers.removeAll()
    }
    public func observe() -> AsyncStream<EmulatorSnapshot> {
        let pair = AsyncStream<EmulatorSnapshot>.makeStream(bufferingPolicy: .bufferingNewest(1))
        subscribers[makeID()] = pair.continuation
        pair.continuation.yield(snapshot)
        return pair.stream
    }
    public func execute(_ command: EmulatorCommand) throws {
        refresh()
        defer { refresh(); publish() }
        do {
            switch command {
            case .start(let encrypted):
                stop(); snapshot.running = true; snapshot.transport = .starting
                server.start(security: encrypted ? .encrypted : .applicationOnly)
                let waiter = waiter
                ticker = Task { [weak self] in
                    while !Task.isCancelled {
                        do { try await waiter.wait() } catch { return }
                        guard !Task.isCancelled, let self, self.snapshot.running else { return }
                        self.engine.advance(seconds: 1)
                        self.server.publishTelemetry()
                        self.ticks += 1
                        if self.ticks.isMultiple(of: 10) {
                            self.record(.telemetry, .info, .system, "Periodic telemetry: 10 simulation ticks")
                        }
                        self.refresh(); self.publish()
                    }
                }
            case .stop: stop()
            case .scenario(let scenario):
                snapshot.scenario = scenario; engine.resetScenario(scenario); server.publishTelemetry()
                record(.telemetry, .info, .local, "Scenario: \(scenario.rawValue)")
            case .resetScenario:
                engine.resetScenario(snapshot.scenario); server.publishTelemetry()
                record(.telemetry, .info, .local, "Scenario controls reset")
            case .resetAll:
                var state = engine.state; state.configuration = .defaults; engine.setState(state)
                engine.resetScenario(snapshot.scenario); server.publishTelemetry()
                record(.configuration, .info, .local, "Scenario and configuration reset")
            case .telemetry(let edit):
                let candidate = try reducer.apply(edit, to: engine.state, scenario: snapshot.scenario)
                guard candidate != engine.state else { break }
                engine.setState(candidate)
                server.publishTelemetry()
                record(.telemetry, .info, .local, "Control: \(String(describing: edit))")
            case .configure(let block, let draft, let revision):
                guard ConfigurationBlock.all.contains(block) else { throw EmulatorOperationError.invalidValues }
                guard snapshot.revisions[block, default: 0] == revision else { throw EmulatorOperationError.conflict }
                try validator.validate(draft)
                var state = engine.state
                state.configuration = block.replacing(in: state.configuration, with: draft)
                try validator.validate(state.configuration)
                guard state.configuration != engine.state.configuration else { break }
                engine.setState(state); server.publishTelemetry()
                record(.configuration, .info, .local, "Applied \(String(describing: block))")
            case .fault(let settings):
                guard settings.isValid else { throw EmulatorOperationError.invalidValues }
                guard !snapshot.running || (!settings.requiresStoppedServer && !snapshot.fault.requiresStoppedServer) else {
                    throw EmulatorOperationError.stopRequired
                }
                engine.setFault(settings.scenario, delay: settings.delay, affected: settings.affected)
                snapshot.fault = settings
                record(.failure, settings.scenario == .none ? .info : .warning, .local, "Fault: \(settings.scenario.rawValue)")
            case .clearActivity: snapshot.activity.removeAll()
            case .savePreset(let name):
                guard storageLoaded else { throw EmulatorOperationError.storageUnavailable }
                let preset = EmulatorPreset(id: makeID(), name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                            scenario: snapshot.scenario, vehicle: engine.state, faults: snapshot.fault)
                let values = snapshot.presets + [preset]
                try presets.save(values); snapshot.presets = values
                record(.preset, .info, .local, "Preset saved")
            case .loadPreset(let id):
                guard !snapshot.running else { throw EmulatorOperationError.stopRequired }
                guard let preset = snapshot.presets.first(where: { $0.id == id }) else { throw EmulatorOperationError.presetUnavailable }
                try validator.validate(preset.vehicle.configuration)
                guard preset.vehicle.hasValidTelemetry, preset.faults.isValid else { throw EmulatorOperationError.invalidValues }
                snapshot.scenario = preset.scenario; snapshot.fault = preset.faults
                engine.setState(preset.vehicle)
                engine.setFault(preset.faults.scenario, delay: preset.faults.delay, affected: preset.faults.affected)
                record(.preset, .info, .local, "Preset loaded")
            case .renamePreset(let id, let name):
                guard let index = snapshot.presets.firstIndex(where: { $0.id == id }), storageLoaded else { throw EmulatorOperationError.presetUnavailable }
                var values = snapshot.presets; values[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                try presets.save(values); snapshot.presets = values
                record(.preset, .info, .local, "Preset renamed")
            case .deletePreset(let id):
                guard storageLoaded else { throw EmulatorOperationError.storageUnavailable }
                let values = snapshot.presets.filter { $0.id != id }
                try presets.save(values); snapshot.presets = values
                record(.preset, .info, .local, "Preset deleted")
            }
        } catch {
            record(.failure, .error, .local, "Command rejected: \(error is EmulatorOperationError ? String(describing: error) : "invalid values or storage failure")")
            throw error
        }
    }
    private func stop() {
        ticker?.cancel(); ticker = nil; ticks = 0; server.stop()
        snapshot.running = false; snapshot.transport = .stopped; snapshot.authentication = .idle
    }
    private func refresh() {
        snapshot.revisions = engine.configurationRevisions
        snapshot.vehicle = engine.state; snapshot.generation = engine.session.generation
    }
    private func publish() {
        for (id, continuation) in subscribers {
            if case .terminated = continuation.yield(snapshot) { subscribers.removeValue(forKey: id) }
        }
    }
    private func record(_ category: ActivityEvent.Category, _ severity: ActivityEvent.Severity,
                        _ origin: ActivityEvent.Origin, _ detail: String) {
        snapshot.activity.append(ActivityEvent(id: makeID(), date: now(), category: category, severity: severity,
                                               origin: origin, generation: engine.session.generation, detail: detail))
        if snapshot.activity.count > 1000 { snapshot.activity.removeFirst(snapshot.activity.count - 1000) }
    }
    private func receive(_ envelope: TransportEvent) {
        guard envelope.generation == engine.session.generation else { return }
        switch envelope.event {
        case .stopped:
            // Start replaces the server synchronously; its queued stop event must not stop the new ticker.
            if !snapshot.running { snapshot.transport = .stopped }
            record(.session, .info, .system, "Server stopped")
        case .waitingForBluetooth: snapshot.transport = .starting; record(.session, .info, .system, "Starting Bluetooth")
        case .advertising: snapshot.transport = .advertising; record(.session, .info, .system, "Advertising synthetic motorcycle")
        case .bluetoothUnavailable: snapshot.transport = .unavailable; snapshot.authentication = .idle
        case .unauthorized: snapshot.transport = .unauthorized
        case .failure:
            stop(); snapshot.transport = .failed
            record(.failure, .error, .system, "Bluetooth transport failed")
        case .session(let phase):
            snapshot.authentication = switch phase { case .idle: .idle; case .challenged: .challenged; case .authenticated: .authenticated }
            record(.session, .info, .bluetooth, "Authentication: \(snapshot.authentication.rawValue)")
        case .transaction(let operation, let characteristic, let bytes):
            record(characteristic == 0x4005 ? .configuration : .session, operation.contains("rejected") ? .warning : .info, .bluetooth,
                   String(format: "%@ %04X (%d bytes)", operation, characteristic, bytes))
        case .subscribed(let characteristic, let maximum):
            record(.session, .info, .bluetooth, String(format: "Subscribe %04X (max %d bytes)", characteristic, maximum))
        case .unsubscribed(let characteristic):
            record(.session, .info, .bluetooth, String(format: "Unsubscribe %04X", characteristic))
        }
        refresh(); publish()
    }
}
