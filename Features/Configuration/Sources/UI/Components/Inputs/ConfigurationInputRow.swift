import SwiftUI
import DesignSystem

struct ConfigurationInputRow: View {
    let field: ConfigurationField
    let edit: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSpace.tiny) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSpace.tiny) {
                    Text(verbatim: field.title)
                    Text(verbatim: "\(field.minimum.formatted()) ... \(field.maximum.formatted()) \(field.unit)").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                TextField(field.title, text: Binding(get: { field.text }, set: { edit($0) }))
                    .monospacedDigit().multilineTextAlignment(.trailing).frame(width: Layout.inputWidth)
                    .textFieldStyle(.roundedBorder)
            }
            if let error = field.error { Text(verbatim: error).font(.caption).foregroundStyle(DesignColor.critical) }
        }.padding(.vertical, DesignSpace.tiny)
    }
    private enum Layout { static let inputWidth: CGFloat = 120 }
}
