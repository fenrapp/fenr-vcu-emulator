import SwiftUI

public struct NumberControl: View {
    private let title: String
    private let value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let unit: String
    private let commit: (Double) -> Void
    @State private var draft: Double
    @State private var dragging = false
    @FocusState private var focused: Bool
    public init(_ title: String, value: Double, range: ClosedRange<Double>, step: Double, unit: String,
                commit: @escaping (Double) -> Void) {
        self.title = title; self.value = value; self.range = range; self.step = step; self.unit = unit
        self.commit = commit; _draft = State(initialValue: value)
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSpace.compact) {
            HStack {
                Text(verbatim: title)
                Spacer()
                TextField(title, value: $draft, format: .number.precision(.fractionLength(0...2)))
                    .multilineTextAlignment(.trailing).monospacedDigit().frame(width: Layout.inputWidth)
                    .focused($focused).onSubmit { commit(draft) }
                Text(verbatim: unit).foregroundStyle(.secondary).font(.caption)
            }
            Slider(value: $draft, in: range, step: step, onEditingChanged: { editing in
                dragging = editing
                if !editing { commit(draft) }
            }).accessibilityLabel(Text(verbatim: title))
        }
        .onChange(of: focused) { _, active in if !active { commit(draft) } }
        .onChange(of: value) { _, value in if !dragging && !focused { draft = value } }
    }
    private enum Layout { static let inputWidth: CGFloat = 88 }
}
