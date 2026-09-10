import Testing
@testable import VehicleSimulation

@Test func scenarioTimeIsDeterministicAndMaintainsBounds() {
    let simulator = ScenarioSimulator()
    var riding = simulator.initialState(for: .riding)
    for _ in 0..<60 { riding = simulator.advance(riding, seconds: 1) }
    #expect(riding.batteryPercent == 74)
    #expect(abs(riding.odometerMeters - (12000 + 35 / 3.6 * 60)) < 0.01)
    var configuration = VehicleConfiguration.defaults
    configuration.charger.target = 1000
    var charging = VehicleState(batteryPercent: 99, isCharging: true, configuration: configuration)
    for _ in 0..<60 { charging = simulator.advance(charging, seconds: 1) }
    #expect(charging.batteryPercent == 100)
    #expect(!charging.isCharging)
    #expect(charging.speedKmh == 0)
    #expect(simulator.initialState(for: .parked) == VehicleState())
    #expect(simulator.advance(riding, seconds: -.infinity) == riding)
}

@Test func resetDiscardsScenarioProgressAndPartialTelemetryIsExplicit() {
    let simulator = ScenarioSimulator()
    let partial = simulator.initialState(for: .partialTelemetry)
    #expect(partial.partialTelemetry)
    let reset = simulator.initialState(for: .charging)
    #expect(reset.simulationSeconds == 0)
    #expect(reset.batteryPercent == 55)
    #expect(!reset.partialTelemetry)
}
