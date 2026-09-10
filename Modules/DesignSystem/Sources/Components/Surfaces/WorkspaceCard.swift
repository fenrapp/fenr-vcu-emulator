import SwiftUI

public struct WorkspaceCard<Content: View>: View {
    private let title: String
    private let symbol: String
    private let content: Content
    public init(_ title: String, symbol: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.symbol = symbol; self.content = content()
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSpace.medium) {
            Label { Text(verbatim: title).font(.headline) } icon: { Image(systemName: symbol).foregroundStyle(DesignColor.accent) }
            content
        }
        .padding(DesignSpace.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignColor.surface, in: RoundedRectangle(cornerRadius: DesignRadius.card))
        .overlay(RoundedRectangle(cornerRadius: DesignRadius.card).strokeBorder(DesignColor.border))
    }
}
