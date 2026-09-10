import SwiftUI

struct TelemetryControl: View {
    let title: LocalizedStringKey
    let value: Double
    let range: ClosedRange<Double>
    let suffix: String
    let commit: (Double) -> Void
    @State private var draft: Double = 0
    @State private var dragging = false

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            HStack {
                Text(title)
                Spacer()
                Text(verbatim: "\(Int(dragging ? draft : value))\(suffix)")
                    .monospacedDigit()
            }
            Slider(value: $draft, in: range, step: 1, onEditingChanged: { editing in
                dragging = editing
                if !editing { commit(draft) }
            })
            .accessibilityLabel(title)
        }
        .onAppear { draft = value }
        .onChange(of: value) { _, new in if !dragging { draft = new } }
    }
    private enum Layout { static let spacing: CGFloat = 8 }
}
