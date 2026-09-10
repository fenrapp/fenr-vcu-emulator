import SwiftUI

public struct MetricTile: View {
    private let title: String
    private let value: String
    private let symbol: String
    public init(_ title: String, value: String, symbol: String) { self.title = title; self.value = value; self.symbol = symbol }
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSpace.small) {
            Image(systemName: symbol).font(.title2).foregroundStyle(DesignColor.accent)
            Text(verbatim: value).font(.system(.largeTitle, design: .rounded, weight: .semibold)).monospacedDigit()
                .minimumScaleFactor(0.65).lineLimit(1)
            Text(verbatim: title).font(.subheadline).foregroundStyle(.secondary)
        }.padding(DesignSpace.large).frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignColor.surface, in: RoundedRectangle(cornerRadius: DesignRadius.card))
    }
}
