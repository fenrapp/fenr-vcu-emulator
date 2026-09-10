import Foundation
import EmulatorDomain
import VehicleSimulation

@MainActor final class ConfigurationRepository: EmulatorRepository {
    var snapshot = EmulatorSnapshot(vehicle: VehicleState(), fault: FaultSettings())
    var applied = 0
    func observe() -> AsyncStream<EmulatorSnapshot> {
        let snapshot = snapshot
        return AsyncStream { $0.yield(snapshot); $0.finish() }
    }
    func execute(_ command: EmulatorCommand) throws {
        if case .configure(let block, let draft, let revision) = command {
            guard snapshot.revisions[block, default: 0] == revision else { throw EmulatorOperationError.conflict }
            applied += 1
            snapshot.vehicle.configuration = block.replacing(in: snapshot.vehicle.configuration, with: draft)
            snapshot.revisions[block, default: 0] += 1
        }
    }
}
