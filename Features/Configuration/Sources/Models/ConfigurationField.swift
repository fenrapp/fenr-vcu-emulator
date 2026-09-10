public struct ConfigurationField: Identifiable {
    public let id: String
    public let title: String
    public var text: String
    public let minimum: Double
    public let maximum: Double
    public let scale: Double
    public let unit: String
    public var error: String?
}
