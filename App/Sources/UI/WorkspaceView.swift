import SwiftUI
import DesignSystem
import SimulationFeature
import ConfigurationFeature
import FailuresFeature
import ActivityFeature

struct WorkspaceView: View {
    @Bindable var model: WorkspaceViewModel
    @State private var section: WorkspaceSection? = .simulation
    var body: some View {
        NavigationSplitView {
            List(WorkspaceSection.allCases, selection: $section) { item in
                Label(item.title, systemImage: item.symbol).tag(item)
            }
            .navigationTitle("FENR")
            .navigationSplitViewColumnWidth(min: WorkspaceLayout.sidebarMinimum, ideal: WorkspaceLayout.sidebarIdeal)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: DesignSpace.compact) {
                    Text("VCU EMULATOR").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text(verbatim: model.identity).font(.caption.monospaced()).textSelection(.enabled)
                    Text("Synthetic motorcycle").font(.caption).foregroundStyle(.secondary)
                }.padding(DesignSpace.medium).frame(maxWidth: .infinity, alignment: .leading)
            }
        } detail: {
            VStack(spacing: 0) {
                SessionBanner(state: model.session, encrypted: model.encrypted, identity: model.identity, pin: model.pin,
                              toggleServer: model.toggleServer, setEncryption: model.setEncryption)
                    .padding(DesignSpace.medium)
                Group {
                    switch section ?? .simulation {
                    case .simulation: SimulationScreen(model: model.simulation)
                    case .configuration: ConfigurationScreen(model: model.configuration)
                    case .failures: FailuresScreen(model: model.failures)
                    case .activity: ActivityScreen(model: model.activity)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                if section != .activity {
                    Button { section = .activity } label: {
                        HStack(spacing: DesignSpace.compact) {
                            Image(systemName: "text.alignleft")
                            Text(verbatim: model.session.latestActivity).lineLimit(1)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }.font(.caption).foregroundStyle(.secondary).padding(DesignSpace.medium)
                    }.buttonStyle(.plain).accessibilityLabel(Text("Open activity log"))
                }
            }
        }
        .tint(DesignColor.accent)
        .frame(minWidth: WorkspaceLayout.minimumWidth, minHeight: WorkspaceLayout.minimumHeight)
        .task { await model.observe() }
        .onDisappear { model.close() }
    }
}
