import SwiftUI
import Charts
import DesignSystem

struct CurveChart: View {
    let points: [CurvePoint]
    var body: some View {
        WorkspaceCard(configurationText("Power and regeneration"), symbol: "chart.xyaxis.line") {
            Chart(points) { point in
                LineMark(x: .value(configurationText("Sample"), point.id), y: .value(configurationText("Percent"), point.power))
                    .foregroundStyle(by: .value(configurationText("Series"), configurationText("Power")))
                LineMark(x: .value(configurationText("Sample"), point.id), y: .value(configurationText("Percent"), point.regeneration))
                    .foregroundStyle(by: .value(configurationText("Series"), configurationText("Regeneration")))
            }.chartYScale(domain: 0...100).frame(height: Layout.chartHeight)
        }
    }
    private enum Layout { static let chartHeight: CGFloat = 190 }
}
