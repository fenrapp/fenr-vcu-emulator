import Foundation
import Testing
import EmulatorDomain
import VehicleSimulation
@testable import EmulatorData

@MainActor @Test func presetPersistenceIsVersionedValidatedAndAtomic() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = LocalPresetStore(directory: directory, fileManager: .default, encoder: JSONEncoder(), decoder: JSONDecoder(), validator: ConfigurationValidator())
    #expect(try store.load().isEmpty)
    var preset = EmulatorPreset(id: UUID(), name: "Parked", scenario: .parked, vehicle: VehicleState(), faults: FaultSettings())
    try store.save([preset]); #expect(try store.load() == [preset])
    preset.vehicle.dcBusVolts = .infinity
    #expect(throws: (any Error).self) { try store.save([preset]) }
    #expect(try store.load().count == 1)
    let url = directory.appendingPathComponent("presets.json")
    try Data("{\"version\":99,\"presets\":[]}".utf8).write(to: url)
    #expect(throws: (any Error).self) { try store.load() }
    try Data("invalid".utf8).write(to: url)
    #expect(throws: (any Error).self) { try store.load() }
}
