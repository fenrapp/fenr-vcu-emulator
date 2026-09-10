import Testing
import EmulatorDomain
@testable import ConfigurationFeature

@MainActor @Test func dirtyDraftRequiresReloadAfterBluetoothChange() async {
    let repository = ConfigurationRepository()
    let model = ConfigurationEditorViewModel(useCases: EmulatorUseCases(repository: repository), mapper: ConfigurationEditorMapper())
    model.edit("power", text: "2000")
    repository.snapshot.vehicle.configuration.charger.power = 1800
    repository.snapshot.revisions[.charger] = 1
    await model.observe()
    #expect(model.state.conflict)
    model.apply()
    #expect(repository.applied == 0)
    model.reload()
    #expect(!model.state.dirty && !model.state.conflict)
    model.edit("power", text: "2200")
    model.apply()
    #expect(repository.applied == 1)
    #expect(repository.snapshot.vehicle.configuration.charger.power == 2200)
}
