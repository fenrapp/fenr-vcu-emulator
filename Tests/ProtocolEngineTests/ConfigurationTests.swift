import Foundation
import Testing
import ProtocolCore
import VehicleSimulation
@testable import ProtocolEngine

@Test func chargingNoOpAndWritePreserveSiblingValues() throws {
    let handler = ConfigurationHandler()
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
    let handler = ConfigurationHandler()
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
