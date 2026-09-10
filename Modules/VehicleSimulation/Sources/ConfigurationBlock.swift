public enum ConfigurationBlock: Hashable, Sendable {
    case charger, lock, map(Int), traction(Int), curve(Int)
    public static var all: [Self] { [.charger, .lock] + (0..<5).flatMap { [.map($0), .traction($0), .curve($0)] } }
    public func replacing(in current: VehicleConfiguration, with draft: VehicleConfiguration) -> VehicleConfiguration {
        var result = current
        switch self {
        case .charger: result.charger = draft.charger
        case .lock: result.lock = draft.lock
        case .map(let i): result.maps[i] = draft.maps[i]; result.maps[i].curve = i + 1
        case .traction(let i): result.traction[i] = draft.traction[i]
        case .curve(let i): result.curves[i] = draft.curves[i]
        }
        return result
    }
    public func changed(from old: VehicleConfiguration, to new: VehicleConfiguration) -> Bool {
        switch self {
        case .charger: old.charger != new.charger
        case .lock: old.lock != new.lock
        case .map(let i): old.maps[i] != new.maps[i]
        case .traction(let i): old.traction[i] != new.traction[i]
        case .curve(let i): old.curves[i] != new.curves[i]
        }
    }
}
