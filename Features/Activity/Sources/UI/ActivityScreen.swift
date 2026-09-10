import SwiftUI
import DesignSystem

public struct ActivityScreen: View {
    @Bindable private var model: ActivityViewModel
    @State private var selection = Set<UUID>()
    public init(model: ActivityViewModel) { self.model = model }
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSpace.medium) {
            Text("Activity", bundle: .module).font(.largeTitle.bold())
            Text("A shareable timeline of the simulated session.", bundle: .module).foregroundStyle(.secondary)
            HStack {
                TextField(activityText("Search activity"), text: Binding(get: { model.query }, set: { model.search($0) }))
                    .textFieldStyle(.roundedBorder)
                Picker(activityText("Category"), selection: Binding(get: { model.category }, set: { model.filterCategory($0) })) {
                    ForEach(model.state.categories) { item in Text(verbatim: item.title).tag(item.id) }
                }.labelsHidden()
                Picker(activityText("Severity"), selection: Binding(get: { model.severity }, set: { model.filterSeverity($0) })) {
                    ForEach(model.state.severities) { item in Text(verbatim: item.title).tag(item.id) }
                }.labelsHidden()
            }
            ViewThatFits(in: .horizontal) {
                HStack { actions }
                VStack(alignment: .leading, spacing: DesignSpace.compact) { actions }
            }
            Table(model.state.rows, selection: $selection) {
                TableColumn(activityText("Time"), value: \.time).width(Layout.timeWidth)
                TableColumn(activityText("Category"), value: \.category).width(Layout.categoryWidth)
                TableColumn(activityText("Detail")) { row in
                    Text(verbatim: row.detail).font(.system(.caption, design: .monospaced))
                        .foregroundStyle(row.severity == "error" ? DesignColor.critical : row.severity == "warning" ? DesignColor.warning : .primary)
                        .textSelection(.enabled)
                }
            }
            HStack {
                Text(verbatim: "\(model.state.rows.count) / \(model.state.total)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                if model.paused { Text("Display paused; capture continues.", bundle: .module).font(.caption).foregroundStyle(DesignColor.warning) }
                Spacer()
                if let message = model.message { Text(verbatim: message).font(.caption) }
            }
        }.padding(DesignSpace.large).task { await model.observe() }
    }
    @ViewBuilder private var actions: some View {
        Button(activityText("Copy selected")) { model.copySelected(selection) }.disabled(selection.isEmpty)
        Button(activityText("Copy filtered"), action: model.copyFiltered)
        Button(activityText("Copy all"), action: model.copyAll)
        Toggle(activityText("Pause display"), isOn: Binding(get: { model.paused }, set: { model.pause($0) })).toggleStyle(.button)
        Button(activityText("Clear"), role: .destructive, action: model.clear)
    }
    private enum Layout { static let timeWidth: CGFloat = 85; static let categoryWidth: CGFloat = 110 }
}
