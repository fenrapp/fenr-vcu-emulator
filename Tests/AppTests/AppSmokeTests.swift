import XCTest
@testable import FENRVCUEmulator

final class AppSmokeTests: XCTestCase {
    @MainActor func testPresentationEditsRemainCoherentWithoutStartingBluetooth() {
        let model = EmulatorComposition.make()
        model.setCharging(true)
        model.setSpeed(35)
        XCTAssertFalse(model.charging)
        XCTAssertEqual(model.speedKmh, 35)
        model.setCharging(true)
        XCTAssertEqual(model.speedKmh, 0)
        model.setBattery(105)
        XCTAssertEqual(model.batteryPercent, 100)
        XCTAssertFalse(model.activity.state.running)
    }
}
