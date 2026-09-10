public struct StarkFirmwareVersion: Comparable, Equatable, Sendable {
    public static let minimumChargePowerControl = StarkFirmwareVersion(major: 1, minor: 9, patch: 1)
    public static let minimumTractionControl = StarkFirmwareVersion(major: 1, minor: 10, patch: 1)
    public static let minimumBikeLockControl = StarkFirmwareVersion(major: 1, minor: 6, patch: 29)

    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init?(_ string: String) {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count >= 3,
              let major = Int(parts[0]),
              let minor = Int(parts[1]),
              let patch = Int(parts[2].prefix(while: { $0.isNumber }))
        else {
            return nil
        }
        self.init(major: major, minor: minor, patch: patch)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }

    public var isChargePowerControlCompatible: Bool {
        self >= Self.minimumChargePowerControl
    }

    public var isTractionControlCompatible: Bool {
        self >= Self.minimumTractionControl
    }

    public var isBikeLockControlCompatible: Bool {
        self >= Self.minimumBikeLockControl
    }

    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}
