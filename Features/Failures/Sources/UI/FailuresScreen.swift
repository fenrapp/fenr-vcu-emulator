import SwiftUI
import DesignSystem

public struct FailuresScreen: View {
    @Bindable private var model: FailureViewModel
    public init(model: FailureViewModel) { self.model = model }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSpace.large) {
                Text("Failures", bundle: .module).font(.largeTitle.bold())
                Text("Repeatable failures, visible recovery.", bundle: .module).foregroundStyle(.secondary)
                WorkspaceCard(failureText("Active profile"), symbol: "waveform.path.ecg") {
                    Picker(failureText("Fault profile"), selection: Binding(get: { model.state.selected }, set: { model.select($0) })) {
                        ForEach(model.state.choices) { item in Text(verbatim: item.title).tag(item.id).disabled(!item.available) }
                    }
                    Text(verbatim: model.state.description).foregroundStyle(.secondary)
                    if model.state.running && model.state.requiresStop {
                        Text("Stop Bluetooth to change or remove this profile.", bundle: .module).foregroundStyle(DesignColor.warning)
                    }
                    if model.state.selected == "delayedResponses" {
                        NumberControl(failureText("Response delay"), value: model.state.delay, range: 0...30, step: 0.5, unit: "s", commit: { model.setDelay($0) })
                    }
                    if model.state.selected == "staleTelemetry" {
                        ForEach(model.state.targets) { item in
                            Toggle(isOn: Binding(get: { item.enabled }, set: { model.setTarget(item.id, enabled: $0) })) { Text(verbatim: item.title).monospaced() }
                        }
                    }
                    Button(failureText("Remove fault")) { model.select("none") }
                        .disabled(model.state.selected == "none" || (model.state.running && model.state.requiresStop))
                }
                WorkspaceCard(failureText("Application silence is not disconnection"), symbol: "antenna.radiowaves.left.and.right") {
                    Text("Stopping advertisements alone does not drop an existing link. Use the documented physical procedure to test real link loss.", bundle: .module)
                }
                if let message = model.message { Text(verbatim: message).foregroundStyle(DesignColor.warning) }
            }.padding(DesignSpace.large)
        }.task { await model.observe() }
    }
}
