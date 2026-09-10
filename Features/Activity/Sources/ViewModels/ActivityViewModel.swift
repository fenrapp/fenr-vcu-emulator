import Foundation
import Observation
import EmulatorDomain

@MainActor @Observable public final class ActivityViewModel {
    public private(set) var state: ActivityViewState
    public private(set) var query = ""
    public private(set) var category = ""
    public private(set) var severity = ""
    public private(set) var paused = false
    public private(set) var message: String?
    private let useCases: EmulatorUseCases
    private let mapper: ActivityMapper
    private let clipboard: any ClipboardWriting
    private let version: String
    private var visibleEvents: [ActivityEvent]
    public init(useCases: EmulatorUseCases, mapper: ActivityMapper, clipboard: any ClipboardWriting, version: String) {
        self.useCases = useCases; self.mapper = mapper; self.clipboard = clipboard; self.version = version
        self.visibleEvents = useCases.current.activity
        self.state = mapper.map(useCases.current.activity, total: useCases.current.activity.count)
    }
    public func observe() async {
        for await snapshot in useCases.observe() {
            guard !Task.isCancelled else { return }
            if !paused { visibleEvents = snapshot.activity; refresh() }
        }
    }
    public func search(_ value: String) { query = value; refresh() }
    public func filterCategory(_ value: String) { category = value; refresh() }
    public func filterSeverity(_ value: String) { severity = value; refresh() }
    public func pause(_ value: Bool) { paused = value; if !value { visibleEvents = useCases.current.activity }; refresh() }
    public func clear() { try? useCases.execute(.clearActivity); visibleEvents = []; refresh() }
    public func copyAll() { copy(useCases.current.activity) }
    public func copyFiltered() { copy(filtered) }
    public func copySelected(_ ids: Set<UUID>) { copy(filtered.filter { ids.contains($0.id) }) }
    private var filtered: [ActivityEvent] { mapper.filtered(visibleEvents, query: query, category: category, severity: severity) }
    private func refresh() { state = mapper.map(filtered, total: visibleEvents.count) }
    private func copy(_ events: [ActivityEvent]) {
        let snapshot = useCases.current
        let text = mapper.export(events, version: version, scenario: snapshot.scenario.rawValue, fault: snapshot.fault.scenario.rawValue)
        message = clipboard.write(text) ? activityText("Copied to clipboard.") : activityText("Could not write to the clipboard.")
    }
}
