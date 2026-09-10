import Foundation

@MainActor
enum TestSupport {
    static func waitUntil(_ condition: () -> Bool) async throws -> Bool {
        for _ in 0..<100 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(5))
        }
        return condition()
    }
}
