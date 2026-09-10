import Foundation

public struct ActivityViewState {
    public var rows: [ActivityRow]
    public var total: Int
    public var categories: [ActivityFilterChoice]
    public var severities: [ActivityFilterChoice]
}
