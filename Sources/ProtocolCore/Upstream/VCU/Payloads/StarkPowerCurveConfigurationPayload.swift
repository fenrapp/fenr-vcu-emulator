public struct StarkPowerCurveConfigurationPayload: StarkPayload {
    public let curve: Int
    public let power: [Int]
    public let regeneration: [Int]

    public init(curve: Int, power: [Int], regeneration: [Int]) {
        self.curve = curve
        self.power = power
        self.regeneration = regeneration
    }
}
