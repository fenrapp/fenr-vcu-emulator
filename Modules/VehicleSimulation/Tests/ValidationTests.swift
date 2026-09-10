import Testing
@testable import VehicleSimulation

@Test func invalidCurvesAndSiblingValuesAreRejected() throws {
    let validator = ConfigurationValidator()
    var state = VehicleConfiguration.defaults
    try validator.validate(state)
    state.curves[0].power.removeLast()
    #expect(throws: ConfigurationValidationError.self) { try validator.validate(state) }
    state = .defaults
    state.charger.startTime = -1
    #expect(throws: ConfigurationValidationError.self) { try validator.validate(state) }
    state = .defaults
    state.traction[1].braking = -1000
    try validator.validate(state)
    state.maps[1].curve = 4
    #expect(throws: ConfigurationValidationError.self) { try validator.validate(state) }
}
@Test func nonfiniteTelemetryCannotReachBinaryEncoding() {
    var state = VehicleState()
    state.dcBusVolts = .infinity
    #expect(!state.hasValidTelemetry)
    state = VehicleState()
    state.charging.reportedCurrent = -.infinity
    #expect(!state.hasValidTelemetry)
}
