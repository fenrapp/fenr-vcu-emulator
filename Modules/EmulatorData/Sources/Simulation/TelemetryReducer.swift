import EmulatorDomain
import VehicleSimulation

public struct TelemetryReducer {
    public init() {}
    public func apply(_ edit: TelemetryEdit, to state: VehicleState, scenario: SimulationScenario) throws -> VehicleState {
        var next = state
        switch edit {
        case .battery(let value): next.batteryPercent = value
        case .health(let value): next.batteryHealthPercent = value
        case .voltage(let value): next.dcBusVolts = value
        case .temperature(let value): next.temperatureCelsius = value
        case .odometer(let value): next.odometerMeters = value
        case .speed(let value):
            guard scenario == .riding else { throw EmulatorOperationError.invalidValues }
            next.speedKmh = value
        case .map(let value): next.mapIndex = value
        case .power(let value): next.signals.poweredOn = value; if !value { next.speedKmh = 0; next.signals.inGear = false }
        case .gear(let value): next.signals.inGear = value
        case .left(let value): next.signals.leftIndicator = value
        case .right(let value): next.signals.rightIndicator = value
        case .hazards(let value): next.signals.leftIndicator = value; next.signals.rightIndicator = value
        case .highBeam(let value): next.signals.highBeam = value
        case .brake(let value): next.signals.brake = value
        case .checkEngine(let value): next.signals.checkEngine = value
        case .chargerConnected(let value):
            next.charging.connected = value
            if !value { next.isCharging = false; next.charging.reportedCurrent = 0 }
        case .charging(let value):
            guard scenario == .charging else { throw EmulatorOperationError.invalidValues }
            next.isCharging = value
            if value { next.charging.connected = true; next.speedKmh = 0 }
        case .interruptCharging: next.isCharging = false; next.charging.reportedCurrent = 0
        case .requestedCurrent(let value): next.charging.requestedCurrent = value
        case .reportedCurrent(let value): next.charging.reportedCurrent = value
        case .chargerType(let value): next.charging.type = value
        case .chargerStatus(let value): next.charging.status = value
        case .targetCellVoltage(let value): next.charging.targetCellVolts = value
        case .stopMovement: next.speedKmh = 0
        }
        guard next.hasValidTelemetry else { throw EmulatorOperationError.invalidValues }
        return next
    }
}
