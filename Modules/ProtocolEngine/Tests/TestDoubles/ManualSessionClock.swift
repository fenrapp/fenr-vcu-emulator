import Foundation
import ProtocolEngine

final class ManualSessionClock: SessionClock, @unchecked Sendable {
    private let lock = NSLock()
    private var time: TimeInterval = 0
    func now() -> TimeInterval { lock.withLock { time } }
    func advance(_ delta: TimeInterval) { lock.withLock { time += delta } }
}
