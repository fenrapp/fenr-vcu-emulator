import SwiftUI
import DesignSystem

public struct SimulationScreen: View {
    @Bindable private var model: SimulationViewModel
    public init(model: SimulationViewModel) { self.model = model }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSpace.large) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSpace.tiny) {
                        Text("Simulation", bundle: .module).font(.largeTitle.bold())
                        Text("A synthetic motorcycle. Real app behavior.", bundle: .module).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Picker(simulationText("Scenario"), selection: Binding(get: { model.state.scenarioID }, set: { model.selectScenario($0) })) {
                        Text("Parked", bundle: .module).tag("parked")
                        Text("Riding", bundle: .module).tag("riding")
                        Text("Charging", bundle: .module).tag("charging")
                        Text("Partial telemetry", bundle: .module).tag("partialTelemetry")
                    }.labelsHidden().fixedSize()
                }
                if model.state.partial {
                    WorkspaceCard(simulationText("Battery-only scenario"), symbol: "exclamationmark.triangle") {
                        Text("FENR may wait for live telemetry because the other five startup datasets are intentionally absent.", bundle: .module)
                        Button(simulationText("Return to Parked")) { model.selectScenario("parked") }
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSpace.medium) {
                    MetricTile(simulationText("Battery"), value: model.state.battery, symbol: "battery.75percent")
                    MetricTile(simulationText("Speed"), value: model.state.speed, symbol: "speedometer")
                    if model.state.charging {
                        MetricTile(simulationText("Delivered power"), value: model.state.deliveredPower, symbol: "bolt.fill")
                        MetricTile(simulationText("Requested power"), value: model.state.requestedPower, symbol: "bolt.badge.clock")
                    }
                }
                if let message = model.message { Text(verbatim: message).foregroundStyle(DesignColor.warning) }
                HStack {
                    Button(action: model.reset) { Text("Reset scenario", bundle: .module) }
                    Button(action: model.resetAll) { Text("Reset all values", bundle: .module) }
                    Spacer()
                    if model.state.scenarioID == "riding" { Button(action: model.stopMovement) { Text("Stop movement", bundle: .module) } }
                    if model.state.charging { Button(action: model.interruptCharging) { Text("Interrupt charging", bundle: .module) } }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: SimulationLayout.cardMinimum))], alignment: .leading, spacing: DesignSpace.medium) {
                    ForEach(model.state.controls) { item in
                        WorkspaceCard(item.title, symbol: "slider.horizontal.3") {
                            NumberControl(item.title, value: item.value, range: item.range, step: item.step, unit: item.unit, showsTitle: false) {
                                model.number(item.id, $0)
                            }
                        }
                    }
                }
                WorkspaceCard(simulationText("Signals and state"), symbol: "light.beacon.max") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: SimulationLayout.cardMinimum))], alignment: .leading, spacing: DesignSpace.medium) {
                        ForEach(model.state.signals) { item in
                            Toggle(isOn: Binding(get: { item.enabled }, set: { model.toggle(item.id, $0) })) {
                                Text(verbatim: item.title)
                            }.toggleStyle(.switch)
                        }
                    }
                }
                PresetPanel(presets: model.state.presets, running: model.state.running,
                            save: model.savePreset, load: model.loadPreset, rename: model.renamePreset, delete: model.deletePreset)
            }.padding(DesignSpace.large)
        }.task { await model.observe() }
    }
}
