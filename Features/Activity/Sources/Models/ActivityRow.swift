import Foundation

public struct ActivityRow: Identifiable {
    public let id: UUID
    public let time: String
    public let category: String
    public let origin: String
    public let detail: String
    public let severity: String
}
