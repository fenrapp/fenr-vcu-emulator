import SwiftUI

@main
struct EmulatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: WindowLayout.width, height: WindowLayout.height)
    }
}

private enum WindowLayout {
    static let width: CGFloat = 760
    static let height: CGFloat = 600
}
