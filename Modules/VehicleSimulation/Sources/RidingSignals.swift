public struct RidingSignals: Equatable, Codable, Sendable {
    public var poweredOn = true
    public var inGear = false
    public var leftIndicator = false
    public var rightIndicator = false
    public var highBeam = false
    public var brake = false
    public var checkEngine = false
    public init() {}
}
