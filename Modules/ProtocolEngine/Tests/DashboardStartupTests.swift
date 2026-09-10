import Foundation
import Testing
import ProtocolCore
@testable import ProtocolEngine

@MainActor @Test func authenticatedStartupProvidesEveryRequiredClientDatasetAtItsWireUUID() throws {
    let engine = try EngineTestFactory.make()
    let client = UUID()
    try EngineTestFactory.authenticate(engine, central: client)
    engine.session.unsubscribe(central: client, characteristic: .security)
    for expected in DashboardStartupFixture.requiredSamples {
        let characteristic = try #require(CharacteristicID.allCases.first { $0.uuid == expected.uuid })
        let initial = try #require(try engine.subscribe(central: client, characteristic: characteristic))
        #expect(initial.characteristic.uuid == expected.uuid)
        #expect(initial.data.count == expected.length)
        #expect(try engine.read(central: client, characteristic: characteristic, offset: 0) == initial.data)
    }
    #expect(Set(engine.telemetry().map { $0.characteristic.uuid }) == Set(DashboardStartupFixture.requiredSamples.map(\.uuid)))
    #expect(CharacteristicID.battery.uuid != DashboardStartupFixture.batteryParametersUUID)
    let battery = try #require(engine.telemetry().first { $0.characteristic.rawValue == 0x6004 })
    #expect(battery.data == Data([75, 0, 98, 0, 16, 14]))
    var changed = engine.state
    changed.batteryPercent = 42
    engine.setState(changed)
    let update = try #require(engine.telemetry().first { $0.characteristic.rawValue == 0x6004 })
    #expect(update.data == Data([42, 0, 98, 0, 16, 14]))
}
