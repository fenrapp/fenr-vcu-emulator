import Foundation

protocol TickWaiting: Sendable {
    func wait() async throws
}

struct SystemTickWaiter: TickWaiting {
    func wait() async throws { try await Task.sleep(for: .seconds(1)) }
}
