import BLEPeripheral
public struct TransportEvent: Sendable {
    public let generation: UInt64
    public let event: PeripheralEvent
    public init(generation: UInt64, event: PeripheralEvent) { self.generation = generation; self.event = event }
}
