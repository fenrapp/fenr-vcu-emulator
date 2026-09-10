public struct ChargingTelemetry: Equatable, Codable, Sendable {
    public var connected = false
    public var requestedCurrent: Double = 4
    public var reportedCurrent: Double = 4
    public var targetCellVolts: Double = 4.2
    public var type: Int = 0
    public var status: Int = 0
    public init() {}
}
