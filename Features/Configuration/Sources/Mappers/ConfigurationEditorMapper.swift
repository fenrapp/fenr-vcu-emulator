import Foundation
import EmulatorDomain
import VehicleSimulation

public struct ConfigurationEditorMapper {
    public init() {}
    public func choices() -> [ConfigurationChoice] {
        ConfigurationBlock.all.enumerated().map { index, block in
            let title: String
            switch block {
            case .charger: title = configurationText("Charging")
            case .lock: title = configurationText("Bike lock")
            case .map(let i): title = configurationText("Map \(i + 1)")
            case .traction(let i): title = configurationText("Traction \(i + 1)")
            case .curve(let i): title = configurationText("Curves \(i + 1)")
            }
            return .init(id: index, title: title)
        }
    }
    public func fields(_ value: VehicleConfiguration, block: ConfigurationBlock) -> [ConfigurationField] {
        switch block {
        case .charger:
            let c = value.charger
            return [field("power", configurationText("Power limit"), c.power, 300, 3300, unit: "W"),
                    field("target", configurationText("Charge target"), c.target, 1, 100, scale: 10, unit: "%"),
                    field("current", configurationText("Maximum current"), c.current, 0, 6553.5, scale: 10, unit: "A"),
                    field("minimumCurrent", configurationText("Minimum current (raw)"), c.minimumCurrent, 0, 65535),
                    field("startTime", configurationText("Start time (raw)"), c.startTime, 0, 65535),
                    field("rampTime", configurationText("Ramp time (raw)"), c.rampTime, 0, 65535),
                    field("standardMaximum", configurationText("Standard maximum"), c.standardMaximum, 0, 65535, unit: "W"),
                    field("backpackMaximum", configurationText("Backpack maximum"), c.backpackMaximum, 0, 65535, unit: "W")]
        case .lock:
            return [field("locked", configurationText("Locked (0 off, 1 on)"), value.lock.isLocked ? 1 : 0, 0, 1),
                    field("timeout", configurationText("Lock timeout (raw)"), value.lock.timeout, -32768, 32767)]
        case .map(let i):
            return [field("torque", configurationText("Torque"), value.maps[i].torque, 0, 100, unit: "%"),
                    field("regen", configurationText("Regeneration"), value.maps[i].regeneration, -100, 100, unit: "%")]
        case .traction(let i):
            return [field("powerTraction", configurationText("Power traction"), value.traction[i].power, -100, 100, scale: 10, unit: "%"),
                    field("brakeTraction", configurationText("Braking traction"), value.traction[i].braking, -100, 100, scale: 10, unit: "%")]
        case .curve(let i):
            return (0..<15).flatMap { sample in
                [field("p\(sample)", configurationText("Power sample \(sample + 1)"), value.curves[i].power[sample], 0, 100, scale: 10, unit: "%"),
                 field("r\(sample)", configurationText("Regeneration sample \(sample + 1)"), value.curves[i].regeneration[sample], 0, 100, scale: 10, unit: "%")]
            }
        }
    }
    public func points(_ fields: [ConfigurationField]) -> [CurvePoint] {
        guard fields.first?.id == "p0" else { return [] }
        return (0..<15).compactMap { i in
            guard let p = fields.first(where: { $0.id == "p\(i)" }), let r = fields.first(where: { $0.id == "r\(i)" }),
                  let power = parse(p.text), let regen = parse(r.text) else { return nil }
            return .init(id: i + 1, power: power, regeneration: regen)
        }
    }
    public func validated(_ fields: [ConfigurationField]) -> [ConfigurationField] {
        fields.map { field in
            var field = field
            guard let value = parse(field.text), value.isFinite,
                  (field.minimum...field.maximum).contains(value),
                  abs(value * field.scale - (value * field.scale).rounded()) < 0.00001,
                  field.id != "target" || value.rounded() == value else {
                field.error = configurationText("Enter a value in range with a supported precision."); return field
            }
            field.error = nil; return field
        }
    }
    public func applying(_ fields: [ConfigurationField], block: ConfigurationBlock, to original: VehicleConfiguration) throws -> VehicleConfiguration {
        guard ConfigurationBlock.all.contains(block) else { throw EmulatorOperationError.invalidValues }
        let schema = self.fields(original, block: block)
        guard fields.count == schema.count, Set(fields.map(\.id)).count == fields.count,
              Set(fields.map(\.id)) == Set(schema.map(\.id)) else { throw EmulatorOperationError.invalidValues }
        let checked = validated(schema.map { expected in
            var field = expected
            field.text = fields.first(where: { $0.id == expected.id })?.text ?? ""
            return field
        })
        guard checked.allSatisfy({ $0.error == nil }) else { throw EmulatorOperationError.invalidValues }
        var value = original
        let numbers = Dictionary(uniqueKeysWithValues: checked.map { ($0.id, Int((parse($0.text)! * $0.scale).rounded())) })
        switch block {
        case .charger:
            value.charger.power = numbers["power"]!; value.charger.target = numbers["target"]!
            value.charger.current = numbers["current"]!; value.charger.minimumCurrent = numbers["minimumCurrent"]!
            value.charger.startTime = numbers["startTime"]!; value.charger.rampTime = numbers["rampTime"]!
            value.charger.standardMaximum = numbers["standardMaximum"]!; value.charger.backpackMaximum = numbers["backpackMaximum"]!
        case .lock: value.lock.isLocked = numbers["locked"] == 1; value.lock.timeout = numbers["timeout"]!
        case .map(let i): value.maps[i].torque = numbers["torque"]!; value.maps[i].regeneration = numbers["regen"]!; value.maps[i].curve = i + 1
        case .traction(let i): value.traction[i].power = numbers["powerTraction"]!; value.traction[i].braking = numbers["brakeTraction"]!
        case .curve(let i):
            value.curves[i].power = (0..<15).map { numbers["p\($0)"]! }
            value.curves[i].regeneration = (0..<15).map { numbers["r\($0)"]! }
        }
        return value
    }
    private func parse(_ text: String) -> Double? { Double(text.replacingOccurrences(of: ",", with: ".")) }
    private func field(_ id: String, _ title: String, _ raw: Int, _ min: Double, _ max: Double, scale: Double = 1, unit: String = "") -> ConfigurationField {
        .init(id: id, title: title, text: String(Double(raw) / scale), minimum: min, maximum: max, scale: scale, unit: unit)
    }
}
