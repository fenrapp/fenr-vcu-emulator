import SwiftUI

@main struct EmulatorApp: App {
    @State private var model: WorkspaceViewModel
    init() { _model = State(initialValue: EmulatorComposition.make()) }
    var body: some Scene {
        Window("FENR VCU Emulator", id: "workspace") {
            WorkspaceView(model: model)
        }
        .defaultSize(width: WorkspaceLayout.initialWidth, height: WorkspaceLayout.initialHeight)
        .windowResizability(.contentMinSize)
    }
}
