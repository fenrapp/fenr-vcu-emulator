import Foundation
import BLEPeripheral
import ProtocolCore
import EmulatorDomain

@MainActor final class RuntimeServer: PeripheralServing {
    var starts = 0; var stops = 0; var publications = 0
    func start(security: LinkSecurity) { starts += 1 }
    func stop() { stops += 1 }
    func publishTelemetry() { publications += 1 }
}
@MainActor final class MemoryPresets: PresetStoring {
    var values: [EmulatorPreset] = []
    var fail = false
    func load() throws -> [EmulatorPreset] { if fail { throw EmulatorOperationError.storageUnavailable }; return values }
    func save(_ presets: [EmulatorPreset]) throws { if fail { throw EmulatorOperationError.storageUnavailable }; values = presets }
}
struct LongTick: TickWaiting { func wait() async throws { try await Task.sleep(for: .seconds(600)) } }
