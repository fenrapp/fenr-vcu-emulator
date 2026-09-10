import Foundation

public struct ActivityEvent: Identifiable, Equatable, Sendable {
    public enum Category: String, CaseIterable, Sendable { case session, telemetry, configuration, failure, preset }
    public enum Severity: String, CaseIterable, Sendable { case info, warning, error }
    public enum Origin: String, Sendable { case local, bluetooth, system }
    public let id: UUID
    public let date: Date
    public let category: Category
    public let severity: Severity
    public let origin: Origin
    public let generation: UInt64
    public let detail: String
    public init(id: UUID, date: Date, category: Category, severity: Severity, origin: Origin,
                generation: UInt64, detail: String) {
        self.id = id; self.date = date; self.category = category; self.severity = severity
        self.origin = origin; self.generation = generation; self.detail = detail
    }
}
