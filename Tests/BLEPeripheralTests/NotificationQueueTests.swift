import Foundation
import Testing
import ProtocolCore
import ProtocolEngine
@testable import BLEPeripheral

@Test func boundedQueueCoalescesTelemetryButPreservesControlResults() {
    let central = UUID()
    var queue = NotificationQueue(capacity: 2)
    let old = ProtocolNotification(central: central, characteristic: .battery, data: Data([10]), generation: 1)
    let fresh = ProtocolNotification(central: central, characteristic: .battery, data: Data([20]), generation: 1)
    let auth = ProtocolNotification(central: central, characteristic: .security, data: Data([1]), generation: 1)
    let insertedOld = queue.append(old)
    #expect(insertedOld)
    let insertedFresh = queue.append(fresh)
    #expect(insertedFresh)
    #expect(queue.count == 1)
    #expect(queue.first == fresh)
    let insertedAuth = queue.append(auth)
    #expect(insertedAuth)
    let insertedOverflow = queue.append(auth)
    #expect(!insertedOverflow)
    queue.removeFirst()
    #expect(queue.first == auth)
    queue.clear()
    #expect(queue.count == 0)
}
