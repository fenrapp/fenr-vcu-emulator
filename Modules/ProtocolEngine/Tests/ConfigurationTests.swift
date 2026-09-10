import Foundation
import Testing
import ProtocolCore
import VehicleSimulation
@testable import ProtocolEngine

@Test func chargingNoOpAndWritePreserveSiblingValues() throws {
    let handler = ConfigurationHandler(validator: ConfigurationValidator())
    var state = VehicleConfiguration.defaults
    let initial = try handler.handle(Data([0,4]), configuration: &state)
    #expect(initial == Data([0,4,0,200,0,220,5,32,3,10,0,0,0,0,0,228,12,228,12]))
    let parsed = try StarkChargerConfigurationCommand.decodeResponse(initial)
    let before = state
    _ = try handler.handle(StarkChargerConfigurationCommand.encodeWrite(parsed), configuration: &state)
    #expect(state == before)
    _ = try handler.handle(Data([1,4,1,200,0,208,7,32,3,228,12,228,12]), configuration: &state)
    #expect(state.charger.power == 2000)
    #expect(state.charger.target == 800)
    #expect(state.charger.minimumCurrent == 10)
    #expect(state.maps == before.maps)
}

@Test func baseMapWriteNormalizesSelectorAndInvalidRequestIsAtomic() throws {
    let handler = ConfigurationHandler(validator: ConfigurationValidator())
    var state = VehicleConfiguration.defaults
    state.maps[0].curve = 0
    let before = state
    let response = try handler.handle(Data([0,0,0]), configuration: &state)
    let parsed = try StarkPowerModeConfigurationCommand.decodeResponse(response, expectedMapIndex: 0)
    _ = try handler.handle(StarkPowerModeConfigurationCommand.noOpWritePacket(configuration: parsed), configuration: &state)
    #expect(state.maps[0].curve == 1)
    #expect(state.maps[0].torque == before.maps[0].torque)
    let valid = state
    #expect(throws: ProtocolFailure.self) { try handler.handle(Data([1,0,0,1,70,0,20,0,0]), configuration: &state) }
    #expect(state == valid)
    #expect(throws: ProtocolFailure.self) { try handler.handle(Data([0,9]), configuration: &state) }
}

@Test func tractionPreservesBothSignedTenthsAndRejectsWrongMode() throws {
    let handler = ConfigurationHandler(validator: ConfigurationValidator())
    var state = VehicleConfiguration.defaults
    let result = try handler.handle(Data([1,8,1,2,15,133,255,200,1]), configuration: &state)
    #expect(result == Data([1,8,0]))
    let bytes = try handler.handle(Data([0,8,2]), configuration: &state)
    #expect(bytes == Data([0,8,0,2,133,255,200,1]))
    let parsed = try StarkTractionControlConfigurationCommand.decodeResponse(bytes, expectedMapIndex: 2)
    #expect(parsed.powerRaw == -123)
    #expect(parsed.brakingRaw == 456)
    let before = state
    #expect(throws: ProtocolFailure.self) {
        try handler.handle(Data([1,8,1,2,0,0,0,0,0]), configuration: &state)
    }
    #expect(state == before)
    #expect(state.traction[0].power == 200)
}

@Test func lockRoundTripPreservesTypeAndTimeoutAndUpdatesTelemetry() throws {
    let handler = ConfigurationHandler(validator: ConfigurationValidator())
    var state = VehicleConfiguration.defaults
    _ = try handler.handle(Data([1,5,0x83,1,1,30,0]), configuration: &state)
    let response = try handler.handle(Data([0,5]), configuration: &state)
    #expect(response == Data([0,5,0,1,1,30,0]))
    let parsed = try StarkBikeLockConfigurationCommand.decodeResponse(response)
    let before = state
    _ = try handler.handle(StarkBikeLockConfigurationCommand.noOpWritePacket(configuration: parsed), configuration: &state)
    #expect(state == before)
    let vehicle = VehicleState(configuration: state)
    let status = try TelemetryEncoder().encode(vehicle, characteristic: .status)
    #expect(status[10] == 1)
    #expect(status[11] == 30)
}

@Test func advancedCurvesUseDistinctWriteAndReadLayouts() throws {
    let handler = ConfigurationHandler(validator: ConfigurationValidator())
    var state = VehicleConfiguration.defaults
    let curve = StarkPowerCurveConfigurationPayload(curve: 3, power: Array(100...114), regeneration: Array(200...214))
    let packet = try StarkPowerCurveConfigurationCommand.writePacket(curve)
    #expect(packet.count == 68)
    _ = try handler.handle(packet, configuration: &state)
    let response = try handler.handle(Data([0,1,3]), configuration: &state)
    #expect(response.count == 64)
    #expect(response.prefix(12) == Data([0,1,0,3,100,0,200,0,101,0,201,0]))
    let parsed = try StarkPowerCurveConfigurationCommand.decodeResponse(response, expectedCurve: 3)
    #expect(parsed.power == curve.power)
    #expect(parsed.regeneration == curve.regeneration)
    let before = state
    _ = try handler.handle(StarkPowerCurveConfigurationCommand.writePacket(parsed), configuration: &state)
    #expect(state == before)
    #expect(state.curves[0].power == Array(repeating: 800, count: 15))
}
