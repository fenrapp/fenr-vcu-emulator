import Foundation

public enum CharacteristicID: UInt16, CaseIterable, Sendable {
    case security = 0x1001, status = 0x1002
    case speed = 0x2001, map = 0x2004, totals = 0x2005
    case versions = 0x4001, configuration = 0x4005, brake = 0x4100
    case charger = 0x5001
    case battery = 0x6003, batteryTemperatures = 0x6005
    case inverterTemperatures = 0x7003

    public var uuid: UUID { GATTProfile.uuid(rawValue) }
    public var service: UInt16 { rawValue & 0xF000 }
    public var canWrite: Bool { self == .security || self == .configuration }
    public var isTelemetry: Bool { self != .security && self != .configuration && self != .versions }
}

public enum GATTProfile {
    public static func uuid(_ value: UInt16) -> UUID {
        UUID(uuidString: String(format: "%08X-5374-6172-4B20-467574757265", Int(value)))!
    }
    public static let services: [UInt16] = [0x1000, 0x2000, 0x4000, 0x5000, 0x6000, 0x7000]
}

public enum LinkSecurity: String, CaseIterable, Sendable {
    case encrypted
    case applicationOnly
}
