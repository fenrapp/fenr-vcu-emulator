import ProtocolEngine

public struct NotificationQueue {
    private var values: [ProtocolNotification] = []
    private let capacity: Int
    public var first: ProtocolNotification? { values.first }
    public var count: Int { values.count }

    public init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
    }

    @discardableResult
    public mutating func append(_ value: ProtocolNotification) -> Bool {
        // Telemetry represents current state; control results must retain their ordering.
        if value.characteristic.isTelemetry,
           let index = values.firstIndex(where: {
               $0.central == value.central && $0.characteristic == value.characteristic
                   && $0.generation == value.generation
           }) {
            values[index] = value
            return true
        }
        guard values.count < capacity else { return false }
        values.append(value)
        return true
    }
    public mutating func removeFirst() { if !values.isEmpty { values.removeFirst() } }
    public mutating func clear() { values.removeAll() }
}
