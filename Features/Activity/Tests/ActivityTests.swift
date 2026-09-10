import Foundation
import Testing
import EmulatorDomain
import VehicleSimulation
@testable import ActivityFeature

@MainActor @Test func filtersAndCopySelectionRetainChronologicalContext() {
    let event = ActivityEvent(id: UUID(), date: Date(timeIntervalSince1970: 0), category: .configuration,
                              severity: .info, origin: .local, generation: 7, detail: "Applied charger")
    var snapshot = EmulatorSnapshot(vehicle: VehicleState(), fault: FaultSettings())
    snapshot.activity = [event]
    let repository = ActivityRepository(snapshot: snapshot), clipboard = ClipboardSpy()
    let model = ActivityViewModel(useCases: EmulatorUseCases(repository: repository), mapper: ActivityMapper(), clipboard: clipboard, version: "0.2.0")
    model.search("CHARGER")
    #expect(model.state.rows.count == 1)
    model.copySelected([event.id])
    #expect(clipboard.text.contains("session=7 Applied charger"))
    #expect(clipboard.text.contains("Scenario: parked"))
    #expect(!clipboard.text.contains("FENRTEST"))
    model.filterSeverity("error")
    #expect(model.state.rows.isEmpty)
    model.copyAll()
    #expect(clipboard.text.contains("Applied charger"))
    model.clear()
    #expect(repository.snapshot.activity.isEmpty)
}

@MainActor @Test func pausedDisplayDoesNotPauseCaptureOrCopyAll() async {
    let repository = ActivityRepository(snapshot: .init(vehicle: VehicleState(), fault: FaultSettings()))
    let clipboard = ClipboardSpy()
    let model = ActivityViewModel(useCases: EmulatorUseCases(repository: repository), mapper: ActivityMapper(), clipboard: clipboard, version: "0.2.0")
    model.pause(true)
    repository.snapshot.activity = [.init(id: UUID(), date: Date(), category: .session, severity: .info, origin: .system, generation: 2, detail: "New session")]
    await model.observe()
    #expect(model.state.rows.isEmpty)
    model.copyAll()
    #expect(clipboard.text.contains("New session"))
    model.pause(false)
    #expect(model.state.rows.count == 1)
}
