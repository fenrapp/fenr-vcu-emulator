import Foundation
import Testing
import EmulatorDomain
@testable import EmulatorData

@MainActor @Test func observersReceiveIndependentStreamsAndSurviveNavigation() async throws {
    let (runtime, _, _, _, _) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    var first = runtime.observe().makeAsyncIterator()
    var second = runtime.observe().makeAsyncIterator()
    #expect(await first.next()?.vehicle.batteryPercent == 75)
    #expect(await second.next()?.vehicle.batteryPercent == 75)
    try runtime.execute(.telemetry(.battery(62)))
    #expect(await first.next()?.vehicle.batteryPercent == 62)
    #expect(await second.next()?.vehicle.batteryPercent == 62)
}
@MainActor @Test func stoppedAndReleasedRuntimeCannotKeepPublishing() async throws {
    var fixture = Optional(try RuntimeFactory.make(waiter: ShortTick()))
    let server = try #require(fixture?.2)
    weak var released = fixture?.0
    try fixture?.0.execute(.start(encrypted: true))
    #expect(try await TestSupport.waitUntil { server.publications > 0 })
    try fixture?.0.execute(.start(encrypted: true))
    #expect(server.starts == 2)
    try fixture?.0.execute(.stop)
    let count = server.publications
    try await Task.sleep(for: .milliseconds(20))
    #expect(server.publications == count)
    fixture = nil
    #expect(try await TestSupport.waitUntil { released == nil })
    #expect(server.publications == count)
}
@MainActor @Test func staleTransportFailuresCannotStopRestartedSession() async throws {
    let (runtime, engine, _, _, events) = try RuntimeFactory.make()
    defer { runtime.shutdown() }
    try runtime.execute(.start(encrypted: true))
    let old = engine.session.generation
    try runtime.execute(.start(encrypted: true))
    events.yield(.init(generation: old, event: .failure(.queueFull)))
    events.yield(.init(generation: engine.session.generation, event: .advertising))
    #expect(try await TestSupport.waitUntil { runtime.snapshot.transport == .advertising })
    #expect(runtime.snapshot.running)
}
