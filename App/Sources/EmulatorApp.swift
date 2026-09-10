import SwiftUI

@main
struct EmulatorApp: App {
    @State private var model = EmulatorComposition.make()
    var body: some Scene {
        Window("FENR VCU Emulator", id: "emulator") {
            ContentView(model: model)
        }
        .defaultSize(width: WindowLayout.width, height: WindowLayout.height)
    }
}

private enum WindowLayout {
    static let width: CGFloat = 800
    static let height: CGFloat = 780
}
