import Foundation
import EmulatorDomain

public struct ActivityMapper {
    public init() {}
    public func filtered(_ events: [ActivityEvent], query: String, category: String, severity: String) -> [ActivityEvent] {
        events.filter { event in
            (category.isEmpty || event.category.rawValue == category)
            && (severity.isEmpty || event.severity.rawValue == severity)
            && (query.isEmpty || event.detail.localizedCaseInsensitiveContains(query) || event.origin.rawValue.localizedCaseInsensitiveContains(query))
        }
    }
    public func map(_ events: [ActivityEvent], total: Int) -> ActivityViewState {
        .init(rows: events.reversed().map { event in
            .init(id: event.id, time: event.date.formatted(date: .omitted, time: .standard),
                  category: categoryTitle(event.category), origin: event.origin.rawValue,
                  detail: event.detail, severity: event.severity.rawValue)
        }, total: total,
              categories: [.init(id: "", title: activityText("All categories"))] + ActivityEvent.Category.allCases.map { .init(id: $0.rawValue, title: categoryTitle($0)) },
              severities: [.init(id: "", title: activityText("All levels")), .init(id: "info", title: activityText("Info")),
                           .init(id: "warning", title: activityText("Warning")), .init(id: "error", title: activityText("Error"))])
    }
    public func export(_ events: [ActivityEvent], version: String, scenario: String, fault: String) -> String {
        let header = "FENR VCU Emulator \(version)\nScenario: \(scenario)\nFault: \(fault)\nEvents: \(events.count)\n"
        return header + events.map {
            "\($0.date.formatted(.iso8601)) [\($0.category.rawValue)] [\($0.severity.rawValue)] [\($0.origin.rawValue)] session=\($0.generation) \($0.detail)"
        }.joined(separator: "\n")
    }
    private func categoryTitle(_ category: ActivityEvent.Category) -> String {
        switch category {
        case .session: activityText("Session")
        case .telemetry: activityText("Telemetry")
        case .configuration: activityText("Configuration")
        case .failure: activityText("Failure")
        case .preset: activityText("Preset")
        }
    }
}
