import Foundation
import Testing
import ProtocolCore
@testable import ProtocolEngine

@MainActor @Test func acceptedButUnappliedWritesAreDetectableByFreshReadback() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    engine.setFault(.unappliedWrites)
    try EngineTestFactory.authenticate(engine, central: client)
    _ = try engine.subscribe(central: client, characteristic: .configuration)
    let result = try engine.write(central: client, characteristic: .configuration, offset: 0,
                                  value: Data([1,4,1,200,0,208,7,32,3,228,12,228,12]))
    #expect(result.first?.data == Data([1,4,0]))
    _ = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,4]))
    let fresh = try engine.read(central: client, characteristic: .configuration, offset: 0)
    #expect(try StarkChargerConfigurationCommand.decodeResponse(fresh).chargePowerWatts == 1500)
}

@MainActor @Test func delayedResponsesHaveBoundedDeadlinesAndCannotSurviveReset() throws {
    let clock = ManualSessionClock()
    let engine = try EngineTestFactory.make(clock: clock)
    let client = UUID()
    engine.setFault(.delayedResponses)
    try EngineTestFactory.authenticate(engine, central: client)
    _ = try engine.subscribe(central: client, characteristic: .configuration)
    let responses = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,1,1]))
    let response = try #require(responses.first)
    #expect(response.notBefore == 6)
    clock.advance(5)
    #expect(clock.now() < response.notBefore)
    engine.session.reset()
    clock.advance(1)
    #expect(!engine.session.isCurrent(response))
}

@MainActor @Test func missingResponsesUseNotificationOnlyConfigurationWithoutFalseSuccessData() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    engine.setFault(.missingResponses)
    try EngineTestFactory.authenticate(engine, central: client)
    _ = try engine.subscribe(central: client, characteristic: .configuration)
    let responses = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,4]))
    #expect(responses.isEmpty)
    #expect(!engine.configurationReadable)
    #expect(throws: ProtocolFailure.unsupported) { try engine.read(central: client, characteristic: .configuration, offset: 0) }
}

@MainActor @Test func explicitTractionCommitWorksAfterAReadFailureWithoutBackgroundWrites() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    engine.setFault(.failedTractionRead)
    try EngineTestFactory.authenticate(engine, central: client)
    let before = engine.state.configuration
    #expect(throws: ProtocolFailure.unsupported) {
        try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,8,0]))
    }
    #expect(engine.state.configuration == before)
    _ = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([1,8,1,0,15,100,0,150,0]))
    #expect(engine.state.configuration.traction[0].power == 100)
    #expect(engine.state.configuration.traction[0].braking == 150)
    _ = try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,8,0]))
    let confirmed = try engine.read(central: client, characteristic: .configuration, offset: 0)
    #expect(confirmed == Data([0,8,0,0,100,0,150,0]))
}

@MainActor @Test func authenticationRejectionAndFirmwareCapabilityGuards() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    engine.setFault(.rejectedAuthentication)
    try EngineTestFactory.authenticate(engine, central: client)
    #expect(throws: ProtocolFailure.authenticationRequired) { try engine.read(central: client, characteristic: .battery, offset: 0) }
    engine.setFault(.unsupportedFirmware)
    try EngineTestFactory.authenticate(engine, central: client)
    let version = try engine.read(central: client, characteristic: .versions, offset: 0)
    #expect(StarkFirmwareVersionParser.parseVCUPic(from: version)?.isTractionControlCompatible == false)
    #expect(throws: ProtocolFailure.unsupported) { try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,4])) }
    engine.setFault(.unsupportedCapabilities)
    #expect(throws: ProtocolFailure.unsupported) { try engine.write(central: client, characteristic: .configuration, offset: 0, value: Data([0,1,1])) }
}

@MainActor @Test func staleAndMalformedTelemetryAreExplicitAndRecoverable() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    try EngineTestFactory.authenticate(engine, central: client)
    engine.setFault(.staleTelemetry)
    var changed = engine.state
    changed.batteryPercent = 20
    engine.setState(changed)
    #expect(try engine.read(central: client, characteristic: .battery, offset: 0) == Data([75,0,98,0]))
    engine.setFault(.none)
    #expect(try engine.read(central: client, characteristic: .battery, offset: 0) == Data([20,0,98,0]))
    engine.setFault(.malformedTelemetry)
    #expect(try engine.read(central: client, characteristic: .speed, offset: 0) == Data([0]))
}
