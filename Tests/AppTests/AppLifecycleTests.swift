import XCTest
@testable import FENRVCUEmulator

final class AppLifecycleTests: XCTestCase {
    @MainActor func testStopCancelsPublicationAndRestartDoesNotRetainOldTicker() async throws {
        let (model, server) = try AppTestFactory.make()
        model.start()
        let firstTick = try await TestSupport.waitUntil { server.publications > 0 }
        XCTAssertTrue(firstTick)
        model.start()
        XCTAssertEqual(server.starts, 2)
        model.stop()
        let count = server.publications
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(server.publications, count)
        XCTAssertFalse(model.activity.state.running)
    }

    @MainActor func testDeinitStopsPeripheralAndReleasesViewModel() async throws {
        var pair: (EmulatorViewModel, RecordingPeripheralServer)? = try AppTestFactory.make()
        let modelReleased = { [weak model = pair?.0] in model == nil }
        let server = try XCTUnwrap(pair?.1)
        pair?.0.start()
        let firstTick = try await TestSupport.waitUntil { server.publications > 0 }
        XCTAssertTrue(firstTick)
        pair = nil
        let released = try await TestSupport.waitUntil { modelReleased() && server.stops > 0 }
        XCTAssertTrue(released)
        XCTAssertGreaterThan(server.stops, 0)
        let count = server.publications
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(server.publications, count)
    }
}
