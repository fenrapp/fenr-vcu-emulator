import Foundation
import Testing
import ProtocolCore
@testable import ProtocolEngine

@MainActor @Test func configurationSurvivesReconnectButPendingResponsesDoNot() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    #expect(throws: ProtocolFailure.authenticationRequired) {
        try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,4]))
    }
    try EngineTestFactory.authenticate(engine, central: client)
    _ = try engine.subscribe(central: client, characteristic: .configuration)
    _ = try engine.write(central: client, characteristic: .configuration, offset: 0,
                         value: Data([1,4,1,200,0,208,7,32,3,228,12,228,12]))
    let notifications = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,4]))
    let original = try #require(notifications.first)
    let response = try engine.read(central: client, characteristic: .configuration, offset: 0)
    #expect(try StarkChargerConfigurationCommand.decodeResponse(response).chargePowerWatts == 2000)
    #expect(try engine.read(central: client, characteristic: .configuration, offset: 10) == Data(response.dropFirst(10)))
    engine.session.reset()
    #expect(!engine.session.isCurrent(original))
    try EngineTestFactory.authenticate(engine, central: client)
    #expect(throws: ProtocolFailure.unsupported) { try engine.read(central: client, characteristic: .configuration, offset: 0) }
    _ = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,4]))
    #expect(engine.state.configuration.charger.power == 2000)
    engine.resetScenario(.parked)
    #expect(engine.state.configuration.charger.power == 1500)
    #expect(throws: ProtocolFailure.unsupported) { try engine.read(central: client, characteristic: .configuration, offset: 0) }
}

@MainActor @Test func fullCurveCanBeReadAtOffsetsWithoutInventingNotificationFragments() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    try EngineTestFactory.authenticate(engine, central: client)
    _ = try engine.subscribe(central: client, characteristic: .configuration)
    let notifications = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,1,1]))
    #expect(notifications.count == 1)
    #expect(notifications[0].data.count == 64)
    let tail = try engine.read(central: client, characteristic: .configuration, offset: 32)
    #expect(tail.count == 32)
    #expect(throws: ProtocolFailure.invalidOffset) { try engine.read(central: client, characteristic: .configuration, offset: 65) }
}
