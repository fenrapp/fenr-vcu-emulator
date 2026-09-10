import Foundation
@testable import FENRVCUEmulator

struct FastTickWaiter: TickWaiting {
    func wait() async throws { try await Task.sleep(for: .milliseconds(5)) }
}
