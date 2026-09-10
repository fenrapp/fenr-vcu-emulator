public struct VehicleConfiguration: Equatable, Sendable {
    public var maps: [BaseMap]
    public var charger: Charger

    public init(maps: [BaseMap], charger: Charger) {
        self.maps = maps
        self.charger = charger
    }

    public static var defaults: Self {
        Self(maps: (0..<5).map { BaseMap(torque: 50 + $0 * 10, regeneration: 20, curve: $0 + 1) },
             charger: Charger(current: 200, power: 1500, target: 800, minimumCurrent: 10,
                              startTime: 0, rampTime: 0, standardMaximum: 3300, backpackMaximum: 3300))
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
