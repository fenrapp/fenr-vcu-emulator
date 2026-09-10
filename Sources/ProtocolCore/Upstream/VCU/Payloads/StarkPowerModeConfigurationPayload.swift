public struct StarkPowerModeConfigurationPayload: StarkPayload {
    public let mapIndex: Int
    public let torqueRaw: Int
    public let regenerationRaw: Int
    public let curve: Int

    public init(mapIndex: Int, torqueRaw: Int, regenerationRaw: Int, curve: Int) {
        self.mapIndex = mapIndex
        self.torqueRaw = torqueRaw
        self.regenerationRaw = regenerationRaw
        self.curve = curve
    }

    public var horsepower: Int {
        Int((Double(torqueRaw) / 1.25).rounded())
    }

    public var regenerativeBrakingPercent: Double {
        Double(regenerationRaw)
    }
}
