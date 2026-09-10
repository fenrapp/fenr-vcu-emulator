import SwiftUI

enum WorkspaceSection: String, CaseIterable, Identifiable {
    case simulation, configuration, failures, activity
    var id: Self { self }
    var title: LocalizedStringKey {
        switch self {
        case .simulation: "Simulation"
        case .configuration: "Configuration"
        case .failures: "Failures"
        case .activity: "Activity"
        }
    }
    var symbol: String {
        switch self {
        case .simulation: "speedometer"
        case .configuration: "slider.horizontal.3"
        case .failures: "waveform.path.ecg"
        case .activity: "text.alignleft"
        }
    }
}
