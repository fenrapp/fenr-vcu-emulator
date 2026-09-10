import SwiftUI

public struct GlassSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    public init() {}
    @ViewBuilder public func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(.background, in: RoundedRectangle(cornerRadius: DesignRadius.card))
        } else if #available(macOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: DesignRadius.card))
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignRadius.card))
        }
    }
}
