import Foundation
import Testing
import EmulatorDomain
import VehicleSimulation
@testable import EmulatorData

@MainActor @Test func concurrentBlockChangesRejectDraftButPreserveSiblings() throws {
    let (runtime, engine, _, _, _) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    var draft = engine.state.configuration
    draft.charger.power = 2000
    var fromPhone = engine.state
    fromPhone.configuration.charger.power = 1800
    engine.setState(fromPhone)
    #expect(throws: EmulatorOperationError.conflict) {
        try runtime.execute(.configure(.charger, draft: draft, expectedRevision: 0))
    }
    #expect(engine.state.configuration.charger.power == 1800)
    draft = engine.state.configuration
    draft.maps[0].torque = 65
    try runtime.execute(.configure(.map(0), draft: draft, expectedRevision: 0))
    #expect(engine.state.configuration.charger.power == 1800)
    #expect(engine.state.configuration.maps[0].torque == 65)
}
@MainActor @Test func scenarioResetPreservesConfigurationAndFullResetClearsIt() throws {
    let (runtime, engine, _, _, _) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    var draft = engine.state.configuration; draft.charger.power = 2200
    try runtime.execute(.configure(.charger, draft: draft, expectedRevision: 0))
    try runtime.execute(.scenario(.charging))
    try runtime.execute(.telemetry(.reportedCurrent(2)))
    try runtime.execute(.telemetry(.interruptCharging))
    #expect(engine.state.charging.connected && !engine.state.isCharging)
    #expect(engine.state.charging.reportedCurrent == 0)
    try runtime.execute(.resetScenario)
    #expect(engine.state.configuration.charger.power == 2200)
    try runtime.execute(.resetAll)
    #expect(engine.state.configuration == .defaults)
}
@MainActor @Test func presetsRequireStoppedServerAndLogIsBounded() throws {
    let (runtime, _, server, presets, _) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    try runtime.execute(.savePreset("Morning charge"))
    #expect(presets.values.count == 1)
    try runtime.execute(.start(encrypted: true))
    #expect(throws: EmulatorOperationError.stopRequired) { try runtime.execute(.loadPreset(presets.values[0].id)) }
    try runtime.execute(.stop)
    let publications = server.publications
    try runtime.execute(.loadPreset(presets.values[0].id))
    #expect(!runtime.snapshot.running && server.publications == publications)
    for index in 0..<1010 { try runtime.execute(.telemetry(.battery(74 + index % 2))) }
    #expect(runtime.snapshot.activity.count == 1000)
    try runtime.execute(.clearActivity)
    #expect(runtime.snapshot.activity.isEmpty)
}
@MainActor @Test func rejectedPresetSaveDoesNotUpdateMemory() throws {
    let (runtime, _, _, store, _) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    store.fail = true
    #expect(throws: EmulatorOperationError.self) { try runtime.execute(.savePreset("Test")) }
    #expect(runtime.snapshot.presets.isEmpty)
}

@MainActor @Test func presetRenameAndDeleteAreCommittedOnlyAfterStorageSucceeds() throws {
    let (runtime, _, _, store, _) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    try runtime.execute(.savePreset("Initial"))
    let id = try #require(runtime.snapshot.presets.first?.id)
    try runtime.execute(.renamePreset(id, "Renamed"))
    #expect(store.values.first?.name == "Renamed")
    store.fail = true
    #expect(throws: EmulatorOperationError.self) { try runtime.execute(.deletePreset(id)) }
    #expect(runtime.snapshot.presets.count == 1)
    store.fail = false
    try runtime.execute(.deletePreset(id))
    #expect(runtime.snapshot.presets.isEmpty && store.values.isEmpty)
}
