import SwiftUI

struct ActivityPanel: View {
    let rows: [ActivityRow]
    var body: some View {
        GroupBox("Activity") {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Layout.spacing) {
                    if rows.isEmpty { Text("Start the peripheral to see activity.").foregroundStyle(.secondary) }
                    ForEach(rows.reversed()) { row in
                        HStack(alignment: .top, spacing: Layout.gap) {
                            Text(verbatim: row.time).foregroundStyle(.secondary)
                            Text(verbatim: row.detail).textSelection(.enabled)
                        }.font(.system(.caption, design: .monospaced))
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(Layout.inset)
            }.frame(minHeight: Layout.height)
        }
    }
    private enum Layout {
        static let spacing: CGFloat = 6
        static let gap: CGFloat = 12
        static let inset: CGFloat = 8
        static let height: CGFloat = 140
    }
}
