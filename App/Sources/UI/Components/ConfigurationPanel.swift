import SwiftUI

struct ConfigurationPanel: View {
    let state: ConfigurationViewState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.spacing) {
                Text("Change configuration from FENR on your iPhone. Confirmed emulator values appear here.")
                    .foregroundStyle(.secondary)
                Grid(alignment: .leading, horizontalSpacing: Layout.columnGap, verticalSpacing: Layout.spacing) {
                    GridRow { Text("Charge power (W)"); Text(verbatim: state.chargingPower) }
                    GridRow { Text("Charge target (%)"); Text(verbatim: state.chargeTarget) }
                    GridRow { Text("Bike lock"); Text(verbatim: state.lockStatus) }
                }
                ForEach(state.maps) { map in
                    GroupBox {
                        VStack(alignment: .leading, spacing: Layout.spacing) {
                            Text(verbatim: map.title).font(.headline)
                            Grid(alignment: .leading, horizontalSpacing: Layout.columnGap) {
                                GridRow { Text("Torque (raw)"); Text(verbatim: map.torque) }
                                GridRow { Text("Regeneration (%)"); Text(verbatim: map.regeneration) }
                                GridRow { Text("Power traction (%)"); Text(verbatim: map.powerTraction) }
                                GridRow { Text("Braking traction (%)"); Text(verbatim: map.brakingTraction) }
                            }
                            DisclosureGroup("Advanced curve samples") {
                                VStack(alignment: .leading, spacing: Layout.spacing) {
                                    Text("Power").font(.caption.bold())
                                    Text(verbatim: map.powerCurve)
                                    Text("Regeneration").font(.caption.bold())
                                    Text(verbatim: map.regenerationCurve)
                                }.font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(Layout.inset)
                    }
                }
            }.padding(Layout.inset)
        }
    }
    private enum Layout {
        static let spacing: CGFloat = 10
        static let columnGap: CGFloat = 24
        static let inset: CGFloat = 12
    }
}
