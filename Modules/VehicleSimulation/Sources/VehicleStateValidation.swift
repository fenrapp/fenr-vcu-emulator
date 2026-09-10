extension VehicleState {
    public var hasValidTelemetry: Bool {
        (0...100).contains(batteryPercent) && (0...100).contains(batteryHealthPercent)
        && speedKmh.isFinite && (0...150).contains(speedKmh)
        && dcBusVolts.isFinite && (0...6553.5).contains(dcBusVolts)
        && temperatureCelsius.isFinite && (-20...80).contains(temperatureCelsius)
        && odometerMeters.isFinite && (0...Double(UInt32.max)).contains(odometerMeters)
        && (0..<5).contains(mapIndex) && simulationSeconds.isFinite && simulationSeconds >= 0
        && charging.requestedCurrent.isFinite && (0...6553.5).contains(charging.requestedCurrent)
        && charging.reportedCurrent.isFinite && (0...6553.5).contains(charging.reportedCurrent)
        && charging.targetCellVolts.isFinite && (0...6.5535).contains(charging.targetCellVolts)
        && (0...255).contains(charging.type) && (0...255).contains(charging.status)
        && (!isCharging || (charging.connected && speedKmh == 0))
    }
}
