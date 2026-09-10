import SwiftUI
import DesignSystem

struct SessionBanner: View {
    let state: WorkspaceSessionState
    let encrypted: Bool
    let identity: String
    let pin: String
    let toggleServer: () -> Void
    let setEncryption: (Bool) -> Void
    @State private var showsIdentity = false
    var body: some View {
        HStack(spacing: DesignSpace.medium) {
            Image(systemName: state.running ? "antenna.radiowaves.left.and.right" : "power")
                .font(.title2).foregroundStyle(state.running ? DesignColor.accent : .secondary)
            VStack(alignment: .leading, spacing: DesignSpace.tiny) {
                Text(verbatim: state.transport).font(.headline)
                Text(verbatim: state.authentication).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(verbatim: state.scenario).font(.subheadline).foregroundStyle(.secondary)
            if state.hasFault { Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(DesignColor.warning).accessibilityLabel(Text("Fault profile active")) }
            Button { showsIdentity.toggle() } label: { Image(systemName: "info.circle") }.buttonStyle(.plain)
                .accessibilityLabel(Text("Session details"))
                .popover(isPresented: $showsIdentity) {
                    VStack(alignment: .leading, spacing: DesignSpace.medium) {
                        Text("Session details").font(.headline)
                        Text(verbatim: identity).monospaced().textSelection(.enabled)
                        LabeledContent("Motorcycle PIN") { Text(verbatim: pin).monospaced().textSelection(.enabled) }
                        Toggle("Require Bluetooth link encryption", isOn: Binding(get: { encrypted }, set: { setEncryption($0) })).disabled(state.running)
                        Text("macOS controls pairing. Its PIN dialog may differ from the motorcycle.").font(.caption).foregroundStyle(.secondary)
                    }.padding(DesignSpace.large)
                }
            Button(action: toggleServer) { Text(state.running ? LocalizedStringKey("Stop") : LocalizedStringKey("Start")) }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
                .accessibilityIdentifier("server-toggle")
        }.padding(DesignSpace.medium).modifier(GlassSurface())
    }
}
