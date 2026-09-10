import CoreBluetooth
import Foundation
import ProtocolCore
import ProtocolEngine

@MainActor
public final class PeripheralServer: NSObject, @preconcurrency CBPeripheralManagerDelegate {
    private let engine: EmulatorEngine
    private let event: @MainActor (PeripheralEvent) -> Void
    private var queue: NotificationQueue
    private let clock: any SessionClock
    private var pendingReads: [PendingRead] = []
    private var manager: CBPeripheralManager?
    private var characteristics: [CharacteristicID: CBMutableCharacteristic] = [:]
    private var centrals: [UUID: CBCentral] = [:]
    private var pendingServices = 0
    private var running = false
    private var security: LinkSecurity = .encrypted

    public init(engine: EmulatorEngine, queue: NotificationQueue, clock: any SessionClock,
                event: @escaping @MainActor (PeripheralEvent) -> Void) {
        self.engine = engine
        self.queue = queue
        self.clock = clock
        self.event = event
    }

    public func start(security: LinkSecurity) {
        stop()
        self.security = security
        running = true
        event(.waitingForBluetooth)
        manager = CBPeripheralManager(delegate: self, queue: .main)
    }

    public func stop() {
        running = false
        finishPendingReads(failed: true)
        manager?.stopAdvertising()
        manager?.removeAllServices()
        manager?.delegate = nil
        manager = nil
        pendingServices = 0
        characteristics.removeAll()
        centrals.removeAll()
        queue.clear()
        engine.session.reset()
        event(.stopped)
    }

    public func publishTelemetry() {
        guard running else { return }
        finishPendingReads(failed: false)
        queue.removeTelemetry()
        enqueue(engine.telemetry())
    }

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard active(peripheral) else { return }
        guard peripheral.state == .poweredOn else {
            finishPendingReads(failed: true)
            queue.clear()
            engine.session.reset()
            centrals.removeAll()
            characteristics.removeAll()
            pendingServices = 0
            if peripheral.state == .unauthorized { event(.unauthorized) }
            else { event(.bluetoothUnavailable) }
            return
        }
        publishServices(peripheral)
    }

    private func publishServices(_ peripheral: CBPeripheralManager) {
        guard characteristics.isEmpty else { return }
        pendingServices = GATTProfile.services.count
        for serviceID in GATTProfile.services {
            let service = CBMutableService(type: CBUUID(nsuuid: GATTProfile.uuid(serviceID)), primary: true)
            service.characteristics = CharacteristicID.allCases.filter { $0.service == serviceID }.map { id in
                let readable = id != .configuration || engine.configurationReadable
                var properties: CBCharacteristicProperties = [.notify]
                var permissions: CBAttributePermissions = []
                if readable { properties.insert(.read); permissions.insert(.readable) }
                if id.canWrite { properties.insert(.write); permissions.insert(.writeable) }
                if security == .encrypted {
                    if readable { permissions.insert(.readEncryptionRequired) }
                    properties.insert(.notifyEncryptionRequired)
                    if id.canWrite { permissions.insert(.writeEncryptionRequired) }
                }
                let characteristic = CBMutableCharacteristic(type: CBUUID(nsuuid: id.uuid),
                                                              properties: properties, value: nil,
                                                              permissions: permissions)
                characteristics[id] = characteristic
                return characteristic
            }
            peripheral.add(service)
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard active(peripheral) else { return }
        if let error { fail(error); return }
        pendingServices -= 1
        guard pendingServices == 0 else { return }
        peripheral.startAdvertising([
            CBAdvertisementDataLocalNameKey: engine.session.identity.vin,
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(nsuuid: GATTProfile.uuid(0x1000))]
        ])
    }

    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        guard active(peripheral) else { return }
        if let error { fail(error) } else { event(.advertising) }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard active(peripheral) else { return }
        guard let id = identifier(request.characteristic.uuid) else {
            peripheral.respond(to: request, withResult: .attributeNotFound); return
        }
        do {
            let value = try engine.read(central: request.central.identifier, characteristic: id, offset: request.offset)
            request.value = value
            if id == .configuration && engine.responseDelay > 0 {
                guard pendingReads.count < 32 else {
                    peripheral.respond(to: request, withResult: .insufficientResources)
                    return
                }
                pendingReads.append(PendingRead(request: request, generation: engine.session.generation,
                                                deadline: clock.now() + engine.responseDelay))
            } else {
                peripheral.respond(to: request, withResult: .success)
            }
            event(.transaction(operation: "read", characteristic: id.rawValue, bytes: value.count))
            event(.session(engine.session.phase))
        } catch {
            peripheral.respond(to: request, withResult: attError(error))
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        guard active(peripheral), let first = requests.first else { return }
        // Reject unsupported write batches atomically, before mutating the engine.
        guard requests.count == 1, let id = identifier(first.characteristic.uuid), let value = first.value else {
            peripheral.respond(to: first, withResult: .requestNotSupported); return
        }
        do {
            let notifications = try engine.write(central: first.central.identifier, characteristic: id,
                                                  offset: first.offset, value: value)
            peripheral.respond(to: first, withResult: .success)
            event(.transaction(operation: "write", characteristic: id.rawValue, bytes: value.count))
            event(.session(engine.session.phase))
            enqueue(notifications)
        } catch {
            peripheral.respond(to: first, withResult: attError(error))
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral,
                                  didSubscribeTo characteristic: CBCharacteristic) {
        guard active(peripheral), let id = identifier(characteristic.uuid) else { return }
        do {
            let initial = try engine.subscribe(central: central.identifier, characteristic: id)
            centrals[central.identifier] = central
            event(.subscribed(id.rawValue, maximumBytes: central.maximumUpdateValueLength))
            if let initial { enqueue([initial]) }
        } catch {
            // Core Bluetooth has already accepted the CCCD. Do not grant protocol authorization.
            event(.transaction(operation: "subscription rejected", characteristic: id.rawValue, bytes: 0))
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral,
                                  didUnsubscribeFrom characteristic: CBCharacteristic) {
        guard active(peripheral), let id = identifier(characteristic.uuid) else { return }
        engine.session.unsubscribe(central: central.identifier, characteristic: id)
        if engine.session.central == nil { centrals.removeAll(); queue.clear() }
        event(.unsubscribed(id.rawValue))
        event(.session(engine.session.phase))
    }

    public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        guard active(peripheral) else { return }
        drain()
    }

    private func enqueue(_ notifications: [ProtocolNotification]) {
        for value in notifications {
            guard queue.append(value) else {
                stop()
                event(.failure("Notification queue capacity exceeded"))
                return
            }
        }
        drain()
    }

    private func drain() {
        guard let manager, running else { return }
        while let next = queue.first {
            guard engine.session.isCurrent(next), let central = centrals[next.central],
                  let characteristic = characteristics[next.characteristic] else {
                queue.removeFirst(); continue
            }
            guard next.notBefore <= clock.now() else { return }
            guard next.data.count <= central.maximumUpdateValueLength else {
                stop()
                event(.failure("Payload exceeds negotiated notification limit"))
                return
            }
            guard manager.updateValue(next.data, for: characteristic, onSubscribedCentrals: [central]) else { return }
            queue.removeFirst()
        }
    }

    private struct PendingRead {
        let request: CBATTRequest
        let generation: UInt64
        let deadline: TimeInterval
    }

    private func finishPendingReads(failed: Bool) {
        guard let manager else { pendingReads.removeAll(); return }
        var remaining: [PendingRead] = []
        for pending in pendingReads {
            let stale = pending.generation != engine.session.generation
            if failed || stale || pending.deadline <= clock.now() {
                manager.respond(to: pending.request, withResult: failed || stale ? .unlikelyError : .success)
            } else { remaining.append(pending) }
        }
        pendingReads = remaining
    }

    private func active(_ peripheral: CBPeripheralManager) -> Bool { running && manager === peripheral }
    private func identifier(_ uuid: CBUUID) -> CharacteristicID? {
        CharacteristicID.allCases.first { CBUUID(nsuuid: $0.uuid) == uuid }
    }
    private func fail(_ error: Error) {
        let nsError = error as NSError
        stop()
        event(.failure("\(nsError.domain) code \(nsError.code)"))
    }
    private func attError(_ error: Error) -> CBATTError.Code {
        switch error as? ProtocolFailure {
        case .authenticationRequired: .insufficientAuthorization
        case .busy: .insufficientResources
        case .invalidOffset: .invalidOffset
        case .invalidLength: .invalidAttributeValueLength
        default: .requestNotSupported
        }
    }
}
