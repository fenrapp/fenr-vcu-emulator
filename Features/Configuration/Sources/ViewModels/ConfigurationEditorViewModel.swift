import Foundation
import Observation
import EmulatorDomain
import VehicleSimulation

@MainActor @Observable public final class ConfigurationEditorViewModel {
    public private(set) var state: ConfigurationEditorState
    private let useCases: EmulatorUseCases
    private let mapper: ConfigurationEditorMapper
    private var revision: UInt64
    private var base: VehicleConfiguration
    public init(useCases: EmulatorUseCases, mapper: ConfigurationEditorMapper) {
        self.useCases = useCases; self.mapper = mapper
        self.base = useCases.current.vehicle.configuration
        self.revision = useCases.current.revisions[.charger, default: 0]
        self.state = .init(selected: 0, choices: mapper.choices(), fields: mapper.fields(useCases.current.vehicle.configuration, block: .charger))
    }
    private var block: ConfigurationBlock { ConfigurationBlock.all[state.selected] }
    public func observe() async {
        for await snapshot in useCases.observe() {
            guard !Task.isCancelled else { return }
            if snapshot.revisions[block, default: 0] != revision {
                if state.dirty { state.conflict = true; state.message = configurationText("This block changed on the motorcycle. Reload before applying.") }
                else { reload() }
            }
        }
    }
    public func select(_ index: Int) {
        guard !state.dirty, ConfigurationBlock.all.indices.contains(index) else { return }
        state.selected = index; reload()
    }
    public func edit(_ id: String, text: String) {
        guard let i = state.fields.firstIndex(where: { $0.id == id }) else { return }
        state.fields[i].text = text; state.fields[i].error = nil; state.dirty = true
        state.points = mapper.points(state.fields)
    }
    public func reload() {
        let snapshot = useCases.current
        base = snapshot.vehicle.configuration; revision = snapshot.revisions[block, default: 0]
        state.fields = mapper.fields(base, block: block); state.points = mapper.points(state.fields)
        state.dirty = false; state.conflict = false; state.message = nil
    }
    public func apply() {
        guard state.dirty, !state.conflict else { return }
        state.fields = mapper.validated(state.fields)
        guard state.fields.allSatisfy({ $0.error == nil }) else { return }
        do {
            let draft = try mapper.applying(state.fields, block: block, to: base)
            try useCases.execute(.configure(block, draft: draft, expectedRevision: revision))
            reload(); state.message = configurationText("Configuration applied.")
        } catch EmulatorOperationError.conflict {
            state.conflict = true; state.message = configurationText("This block changed on the motorcycle. Reload before applying.")
        } catch { state.message = configurationText("Configuration rejected. Check the values; a power curve needs at least one nonzero sample.") }
    }
}
