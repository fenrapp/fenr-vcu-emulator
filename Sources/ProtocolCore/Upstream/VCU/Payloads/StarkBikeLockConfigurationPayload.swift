public struct StarkBikeLockConfigurationPayload: Equatable, Sendable {
    public let isLocked: Bool
    public let lockType: UInt8
    public let timeoutSeconds: Int

    public init(isLocked: Bool, lockType: UInt8, timeoutSeconds: Int) {
        self.isLocked = isLocked
        self.lockType = lockType
        self.timeoutSeconds = timeoutSeconds
    }
}
