import SwiftUI

struct ContentView: View {
    @Bindable var model: EmulatorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            HStack {
                VStack(alignment: .leading) {
                    Text("FENR VCU Emulator").font(.title.bold())
                    Text("Physical iPhone. Synthetic motorcycle.").foregroundStyle(.secondary)
                }
                Spacer()
                if model.activity.state.running {
                    Button("Stop", action: { model.stop() })
                } else {
                    Button("Start", action: { model.start() }).buttonStyle(.borderedProminent)
                }
            }
            SessionPanel(identity: model.identityName, pin: model.pairingPIN,
                         transport: model.activity.state.transport, authentication: model.activity.state.authentication)
            Toggle("Require Bluetooth link encryption", isOn: $model.requireEncryption)
                .disabled(model.activity.state.running)
            Text("macOS controls pairing. Its PIN dialog may differ from the motorcycle.")
                .font(.caption).foregroundStyle(.secondary)
            HStack {
                Picker("Scenario", selection: Binding(get: { model.scenarioID }, set: { model.selectScenario($0) })) {
                    ForEach(model.scenarioChoices) { choice in Text(verbatim: choice.title).tag(choice.id) }
                }
                Button("Reset scenario") { model.resetScenario() }
            }
            HStack(spacing: Layout.controlGap) {
                TelemetryControl(title: "Battery", value: model.batteryPercent, range: 0...100,
                                 suffix: "%", commit: { model.setBattery($0) })
                TelemetryControl(title: "Speed", value: model.speedKmh, range: 0...150,
                                 suffix: " km/h", commit: { model.setSpeed($0) })
            }
            HStack(spacing: Layout.controlGap) {
                TelemetryControl(title: "Temperature", value: model.temperatureCelsius, range: -20...80,
                                 suffix: " C", commit: { model.setTemperature($0) })
                Picker("Active map", selection: Binding(get: { model.mapIndex }, set: { model.setMap($0) })) {
                    ForEach(0..<5, id: \.self) { index in Text("Map \(index + 1)").tag(index) }
                }
            }
            Toggle("Charging", isOn: Binding(get: { model.charging }, set: { model.setCharging($0) }))
            ActivityPanel(rows: model.activity.state.activity)
        }
        .padding(Layout.padding)
        .frame(minWidth: Layout.width, minHeight: Layout.height)
        .onDisappear { model.stop() }
    }

    private enum Layout {
        static let spacing: CGFloat = 16
        static let controlGap: CGFloat = 28
        static let padding: CGFloat = 24
        static let width: CGFloat = 700
        static let height: CGFloat = 560
    }
}
