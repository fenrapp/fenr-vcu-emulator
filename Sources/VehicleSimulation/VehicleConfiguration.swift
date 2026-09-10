public struct VehicleConfiguration: Equatable, Sendable {
    public var maps: [BaseMap]
    public var charger: Charger
    public var traction: [Traction]
    public var lock: Lock
    public var curves: [Curve]

    public init(maps: [BaseMap], charger: Charger, traction: [Traction], lock: Lock, curves: [Curve]) {
        self.maps = maps
        self.charger = charger
        self.traction = traction
        self.lock = lock
        self.curves = curves
    }

    public static var defaults: Self {
        Self(maps: (0..<5).map { BaseMap(torque: 50 + $0 * 10, regeneration: 20, curve: $0 + 1) },
             charger: Charger(current: 200, power: 1500, target: 800, minimumCurrent: 10,
                              startTime: 0, rampTime: 0, standardMaximum: 3300, backpackMaximum: 3300),
             traction: (0..<5).map { _ in Traction(power: 200, braking: 300) },
             lock: Lock(isLocked: false, type: 1, timeout: 0),
             curves: (0..<5).map { _ in Curve(power: Array(repeating: 800, count: 15), regeneration: Array(repeating: 200, count: 15)) })
    }

    public struct Curve: Equatable, Sendable {
        public var power: [Int]
        public var regeneration: [Int]
    }

    public struct Traction: Equatable, Sendable {
        public var power: Int
        public var braking: Int
    }

    public struct Lock: Equatable, Sendable {
        public var isLocked: Bool
        public var type: UInt8
        public var timeout: Int
    }

    public struct BaseMap: Equatable, Sendable {
        public var torque: Int
        public var regeneration: Int
        public var curve: Int
    }

    public struct Charger: Equatable, Sendable {
        public var current: Int
        public var power: Int
        public var target: Int
        public var minimumCurrent: Int
        public var startTime: Int
        public var rampTime: Int
        public var standardMaximum: Int
        public var backpackMaximum: Int
    }
}
