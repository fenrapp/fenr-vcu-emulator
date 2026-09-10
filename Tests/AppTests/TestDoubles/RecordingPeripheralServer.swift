import BLEPeripheral
import ProtocolCore
@testable import FENRVCUEmulator

@MainActor
final class RecordingPeripheralServer: PeripheralServing {
    private let activity: ActivityStore
    private(set) var starts = 0
    private(set) var stops = 0
    private(set) var publications = 0
    init(activity: ActivityStore) { self.activity = activity }
    func start(security: LinkSecurity) { starts += 1; activity.receive(.waitingForBluetooth) }
    func stop() { stops += 1; activity.receive(.stopped) }
    func publishTelemetry() { publications += 1 }
}
