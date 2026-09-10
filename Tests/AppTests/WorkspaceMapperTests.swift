import XCTest
import EmulatorDomain
import VehicleSimulation
@testable import FENRVCUEmulator

final class WorkspaceMapperTests: XCTestCase {
    func testSessionPresentationSeparatesAdvertisingFromAuthentication() {
        var snapshot = EmulatorSnapshot(vehicle: VehicleState(), fault: FaultSettings())
        snapshot.transport = .advertising
        snapshot.running = true
        snapshot.authentication = .challenged
        let presentation = WorkspaceSessionMapper().map(snapshot)
        XCTAssertEqual(presentation.transport, "Advertising")
        XCTAssertEqual(presentation.authentication, "Waiting for V2 response")
        XCTAssertTrue(presentation.running)
        XCTAssertFalse(presentation.hasFault)
    }
}
