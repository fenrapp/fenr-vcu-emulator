import Foundation
import Testing
import VehicleSimulation
@testable import ProtocolEngine

@Test func ridingSignalsUseIndependentKnownWireBits() throws {
    var state = VehicleState()
    state.signals.inGear = true
    state.signals.leftIndicator = true
    state.signals.rightIndicator = true
    state.signals.highBeam = true
    state.signals.checkEngine = true
    state.signals.brake = true
    let encoder = TelemetryEncoder()
    let status = try encoder.encode(state, characteristic: .status)
    #expect(Array(status[2..<4]) == [14, 16])
    #expect(Array(status[8..<10]) == [24, 0])
    #expect(try encoder.encode(state, characteristic: .brake) == Data([5,15,1,0,0,0,0,0]))
}

@Test func chargingSeparatesRequestedAndDeliveredCurrentAndRetainsBusVoltage() throws {
    var state = VehicleState(isCharging: true)
    state.charging.requestedCurrent = 8
    state.charging.reportedCurrent = 3.5
    state.dcBusVolts = 355.2
    let encoder = TelemetryEncoder()
    #expect(try encoder.encode(state, characteristic: .battery) == Data([75,0,98,0,224,13]))
    let charging = try encoder.encode(state, characteristic: .charger)
    #expect(Array(charging[0..<4]) == [80,0,35,0])
    state.isCharging = false
    let interrupted = try encoder.encode(state, characteristic: .charger)
    #expect(Array(interrupted[0..<4]) == [80,0,0,0])
    #expect(try encoder.encode(state, characteristic: .status)[8] == 18)
}
