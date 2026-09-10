import SwiftUI
import DesignSystem

struct PresetPanel: View {
    let presets: [PresetChoice]
    let running: Bool
    let save: (String) -> Void
    let load: (UUID) -> Void
    let rename: (UUID, String) -> Void
    let delete: (UUID) -> Void
    @State private var name = ""
    @State private var selected: UUID?
    var body: some View {
        WorkspaceCard(simulationText("Local presets"), symbol: "square.stack.3d.up") {
            Text("Save the current scenario, configuration and faults. Loading requires Bluetooth to be stopped.", bundle: .module).foregroundStyle(.secondary)
            HStack {
                TextField(simulationText("Preset name"), text: $name)
                Button(simulationText("Save new")) { save(name) }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            if !presets.isEmpty {
                Picker(simulationText("Saved preset"), selection: $selected) {
                    Text("Choose a preset", bundle: .module).tag(nil as UUID?)
                    ForEach(presets) { item in Text(verbatim: item.title).tag(Optional(item.id)) }
                }
                HStack {
                    Button(simulationText("Load")) { if let selected { load(selected) } }.disabled(selected == nil || running)
                    Button(simulationText("Rename")) { if let selected { rename(selected, name) } }.disabled(selected == nil || name.isEmpty)
                    Button(simulationText("Delete"), role: .destructive) { if let selected { delete(selected); self.selected = nil } }.disabled(selected == nil)
                }
            }
        }
    }
}
