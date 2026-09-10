import Foundation
import EmulatorDomain
import VehicleSimulation

@MainActor final class ActivityRepository: EmulatorRepository {
    var snapshot: EmulatorSnapshot
    init(snapshot: EmulatorSnapshot) { self.snapshot = snapshot }
    func observe() -> AsyncStream<EmulatorSnapshot> { let value = snapshot; return AsyncStream { $0.yield(value); $0.finish() } }
    func execute(_ command: EmulatorCommand) throws { if case .clearActivity = command { snapshot.activity = [] } }
}
@MainActor final class ClipboardSpy: ClipboardWriting {
    var text = ""
    func write(_ text: String) -> Bool { self.text = text; return true }
}
