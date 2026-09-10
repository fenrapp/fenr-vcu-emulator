public struct StarkTractionControlConfigurationPayload: StarkPayload {
    public let mapIndex: Int
    public let powerRaw: Int
    public let brakingRaw: Int

    public init(mapIndex: Int, powerRaw: Int, brakingRaw: Int) {
        self.mapIndex = mapIndex
        self.powerRaw = powerRaw
        self.brakingRaw = brakingRaw
    }

    public var powerPercent: Double {
        Double(powerRaw) / 10
    }

    public var brakingPercent: Double {
        Double(brakingRaw) / 10
    }
}
