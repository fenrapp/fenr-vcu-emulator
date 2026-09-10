import SwiftUI

struct FaultPanel: View {
    let choices: [ScenarioChoice]
    let selected: String
    let running: Bool
    let select: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text("Failure scenario").font(.headline)
            Picker("Behavior", selection: Binding(get: { selected }, set: { select($0) })) {
                ForEach(choices) { choice in Text(verbatim: choice.title).tag(choice.id) }
            }.disabled(running)
            Text("Stop the peripheral before changing failure scenarios, then reconnect FENR.")
            Text("Missing responses uses a notification-only configuration characteristic so the client can exercise its response timeout.")
            Text("Radio disconnection is a separate physical test. Stopping advertisements alone does not disconnect an existing link.")
            Spacer()
        }.foregroundStyle(.secondary).padding(Layout.inset)
    }
    private enum Layout {
        static let spacing: CGFloat = 16
        static let inset: CGFloat = 16
    }
}
