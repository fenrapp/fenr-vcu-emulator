import Testing
import EmulatorDomain
import VehicleSimulation
@testable import SimulationFeature

@Test func chargingExposesDeliveredPowerAndScenarioSpecificControls() {
    var vehicle = VehicleState(isCharging: true)
    vehicle.charging.reportedCurrent = 3
    var snapshot = EmulatorSnapshot(vehicle: vehicle, fault: FaultSettings())
    snapshot.scenario = .charging
    let mapper = SimulationMapper()
    let charging = mapper.map(snapshot)
    #expect(charging.deliveredPower.contains("080"))
    #expect(charging.controls.contains { $0.id == "reportedCurrent" })
    #expect(!charging.controls.contains { $0.id == "speed" })
    snapshot.scenario = .partialTelemetry
    #expect(mapper.map(snapshot).partial)
}
