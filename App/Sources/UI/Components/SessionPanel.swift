import SwiftUI

struct SessionPanel: View {
    let identity: String
    let pin: String
    let transport: String
    let authentication: String

    var body: some View {
        GroupBox {
            Grid(alignment: .leading, horizontalSpacing: Layout.spacing, verticalSpacing: Layout.rowSpacing) {
                GridRow { Text("Synthetic bike"); Text(verbatim: identity).monospaced() }
                GridRow { Text("Derived motorcycle PIN"); Text(verbatim: pin).monospaced() }
                GridRow { Text("Bluetooth"); Text(verbatim: transport) }
                GridRow { Text("Authentication"); Text(verbatim: authentication) }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(Layout.inset)
        }
    }
    private enum Layout {
        static let spacing: CGFloat = 24
        static let rowSpacing: CGFloat = 8
        static let inset: CGFloat = 8
    }
}
