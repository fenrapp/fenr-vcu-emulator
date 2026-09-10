import AppKit
import EmulatorDomain

public struct SystemTickWaiter: TickWaiting {
    public init() {}
    public func wait() async throws { try await Task.sleep(for: .seconds(1)) }
}
@MainActor public struct SystemClipboard: ClipboardWriting {
    private let pasteboard: NSPasteboard
    public init(pasteboard: NSPasteboard) { self.pasteboard = pasteboard }
    public func write(_ text: String) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
}
