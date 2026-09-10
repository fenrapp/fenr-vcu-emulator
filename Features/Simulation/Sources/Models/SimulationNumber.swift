import Foundation

public struct SimulationNumber: Identifiable {
    public let id: String; public let title: String; public let value: Double
    public let range: ClosedRange<Double>; public let step: Double; public let unit: String
}
