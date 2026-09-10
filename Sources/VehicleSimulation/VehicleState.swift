import Foundation

public struct VehicleState: Equatable, Sendable {
    public var batteryPercent: Int
    public var speedKmh: Double
    public var mapIndex: Int
    public var isCharging: Bool
    public var odometerMeters: Double
    public var temperatureCelsius: Double
    public var partialTelemetry: Bool
    public var configuration: VehicleConfiguration
    public var simulationSeconds: Double = 0

    public init(batteryPercent: Int = 75, speedKmh: Double = 0, mapIndex: Int = 0,
                isCharging: Bool = false, odometerMeters: Double = 12000, temperatureCelsius: Double = 24, partialTelemetry: Bool = false, configuration: VehicleConfiguration = .defaults) {
        self.batteryPercent = min(100, max(0, batteryPercent))
        self.speedKmh = min(150, max(0, speedKmh.isFinite ? speedKmh : 0))
        self.mapIndex = min(4, max(0, mapIndex))
        self.isCharging = isCharging
        self.odometerMeters = odometerMeters
        self.temperatureCelsius = temperatureCelsius
        self.partialTelemetry = partialTelemetry
        self.configuration = configuration
    }
}
