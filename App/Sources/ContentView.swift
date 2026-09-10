import SwiftUI

struct ContentView: View {
    @Bindable var model: EmulatorViewModel
    @State private var section: Section = .dashboard

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.spacing) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("FENR VCU Emulator").font(.title.bold())
                        Text("Physical iPhone. Synthetic motorcycle.").foregroundStyle(.secondary)
                    }
                    Spacer()
                    if model.activity.state.running {
                        Button("Stop") { model.stop() }
                    } else {
                        Button("Start") { model.start() }.buttonStyle(.borderedProminent)
                    }
                }
                SessionPanel(identity: model.identityName, pin: model.pairingPIN,
                             transport: model.activity.state.transport, authentication: model.activity.state.authentication)
                Picker("Section", selection: $section) {
                    Text("Dashboard").tag(Section.dashboard)
                    Text("Configuration").tag(Section.configuration)
                    Text("Failures").tag(Section.failures)
                }.pickerStyle(.segmented).labelsHidden()
                Group {
                    switch section {
                    case .dashboard: DashboardPanel(model: model)
                    case .configuration: ConfigurationPanel(state: model.configurationState)
                    case .failures:
                        FaultPanel(choices: model.faultChoices, selected: model.faultID,
                                   running: model.activity.state.running, select: { model.selectFault($0) })
                    }
                }.frame(height: Layout.panelHeight)
                ActivityPanel(rows: model.activity.state.activity)
            }.padding(Layout.padding)
        }
        .frame(minWidth: Layout.width, minHeight: Layout.height)
        .onDisappear { model.stop() }
    }

    private enum Section { case dashboard, configuration, failures }
    private enum Layout {
        static let spacing: CGFloat = 16
        static let panelHeight: CGFloat = 310
        static let padding: CGFloat = 24
        static let width: CGFloat = 700
        static let height: CGFloat = 620
    }
}
