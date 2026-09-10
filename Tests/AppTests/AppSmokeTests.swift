import XCTest
@testable import FENRVCUEmulator

final class AppSmokeTests: XCTestCase {
    @MainActor func testInitialViewCanBeConstructed() {
        _ = ContentView()
    }
}
