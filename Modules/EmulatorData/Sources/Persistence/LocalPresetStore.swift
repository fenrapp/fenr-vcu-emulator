import Foundation
import EmulatorDomain
import VehicleSimulation

@MainActor public struct LocalPresetStore: PresetStoring {
    private struct Document: Codable { let version: Int; let presets: [EmulatorPreset] }
    private let directory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let validator: ConfigurationValidator
    public init(directory: URL, fileManager: FileManager, encoder: JSONEncoder, decoder: JSONDecoder,
                validator: ConfigurationValidator) {
        self.directory = directory; self.fileManager = fileManager; self.encoder = encoder
        self.decoder = decoder; self.validator = validator
    }
    public func load() throws -> [EmulatorPreset] {
        let url = directory.appendingPathComponent("presets.json")
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        guard (try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) <= 2_000_000 else {
            throw EmulatorOperationError.storageUnavailable
        }
        let document = try decoder.decode(Document.self, from: Data(contentsOf: url))
        guard document.version == 1 else { throw EmulatorOperationError.storageUnavailable }
        try validate(document.presets)
        return document.presets
    }
    public func save(_ presets: [EmulatorPreset]) throws {
        try validate(presets)
        let data = try encoder.encode(Document(version: 1, presets: presets))
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent("presets.json"), options: .atomic)
    }
    private func validate(_ presets: [EmulatorPreset]) throws {
        guard presets.count <= 100, Set(presets.map(\.id)).count == presets.count else {
            throw EmulatorOperationError.invalidValues
        }
        for preset in presets {
            guard !preset.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  preset.name.count <= 80, preset.vehicle.hasValidTelemetry, preset.faults.isValid,
                  (preset.scenario == .partialTelemetry) == preset.vehicle.partialTelemetry,
                  preset.scenario == .riding || preset.vehicle.speedKmh == 0,
                  preset.scenario == .charging || !preset.vehicle.isCharging else {
                throw EmulatorOperationError.invalidValues
            }
            try validator.validate(preset.vehicle.configuration)
        }
    }
}
