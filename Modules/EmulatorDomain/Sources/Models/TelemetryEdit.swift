public enum TelemetryEdit: Sendable {
    case battery(Int), health(Int), voltage(Double), temperature(Double), odometer(Double), speed(Double), map(Int)
    case power(Bool), gear(Bool), left(Bool), right(Bool), hazards(Bool), highBeam(Bool), brake(Bool), checkEngine(Bool)
    case chargerConnected(Bool), charging(Bool), interruptCharging, requestedCurrent(Double), reportedCurrent(Double)
    case chargerType(Int), chargerStatus(Int), targetCellVoltage(Double), stopMovement
}
