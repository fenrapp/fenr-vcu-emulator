import Testing
import EmulatorDomain
import VehicleSimulation
@testable import FailuresFeature

@Test func stoppedOnlyProfilesAreUnavailableDuringAdvertising() {
    var snapshot = EmulatorSnapshot(vehicle: VehicleState(), fault: FaultSettings())
    snapshot.running = true
    let state = FailureMapper().map(snapshot)
    #expect(state.choices.first { $0.id == "missingResponses" }?.available == false)
    #expect(state.choices.first { $0.id == "staleTelemetry" }?.available == true)
}
