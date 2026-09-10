import SwiftUI
import DesignSystem

public struct ConfigurationScreen: View {
    @Bindable private var model: ConfigurationEditorViewModel
    public init(model: ConfigurationEditorViewModel) { self.model = model }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSpace.large) {
                Text("Configuration", bundle: .module).font(.largeTitle.bold())
                Text("Edit a block, then apply it to the simulated motorcycle. iPhone writes appear here too.", bundle: .module).foregroundStyle(.secondary)
                Picker(configurationText("Configuration block"), selection: Binding(get: { model.state.selected }, set: { model.select($0) })) {
                    ForEach(model.state.choices) { choice in Text(verbatim: choice.title).tag(choice.id) }
                }.disabled(model.state.dirty)
                if let message = model.state.message { Text(verbatim: message).foregroundStyle(model.state.conflict ? DesignColor.warning : .secondary) }
                if !model.state.points.isEmpty { CurveChart(points: model.state.points) }
                WorkspaceCard(configurationText("Values"), symbol: "slider.horizontal.3") {
                    ForEach(model.state.fields) { field in
                        ConfigurationInputRow(field: field) { model.edit(field.id, text: $0) }
                    }
                }
                HStack {
                    Button(configurationText("Apply"), action: model.apply).buttonStyle(.borderedProminent)
                        .disabled(!model.state.dirty || model.state.conflict)
                    Button(configurationText("Cancel / Reload"), action: model.reload)
                    if model.state.dirty { Text("Unapplied changes", bundle: .module).foregroundStyle(.secondary) }
                }
            }.padding(DesignSpace.large)
        }.task { await model.observe() }
    }
}
