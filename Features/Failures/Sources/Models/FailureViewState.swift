public struct FailureViewState {
    public var selected: String
    public var choices: [FailureChoice]
    public var description: String
    public var running: Bool
    public var requiresStop: Bool
    public var delay: Double
    public var targets: [FailureTarget]
}
