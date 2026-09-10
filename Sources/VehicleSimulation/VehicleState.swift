import Foundation

public struct VehicleState: Equatable, Sendable {
    public var batteryPercent: Int
    public var speedKmh: Double
    public var mapIndex: Int
    public var isCharging: Bool
    public var odometerMeters: UInt32

    public init(batteryPercent: Int = 75, speedKmh: Double = 0, mapIndex: Int = 0,
                isCharging: Bool = false, odometerMeters: UInt32 = 12000) {
        self.batteryPercent = min(100, max(0, batteryPercent))
        self.speedKmh = min(150, max(0, speedKmh.isFinite ? speedKmh : 0))
        self.mapIndex = min(4, max(0, mapIndex))
        self.isCharging = isCharging
        self.odometerMeters = odometerMeters
    }
}
