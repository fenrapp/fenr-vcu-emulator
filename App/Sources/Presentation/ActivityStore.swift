import Foundation
import Observation
import BLEPeripheral

@MainActor @Observable
final class ActivityStore {
    private(set) var state: EmulatorViewState
    private let mapper: PeripheralEventMapper
    init(state: EmulatorViewState, mapper: PeripheralEventMapper) {
        self.state = state
        self.mapper = mapper
    }
    func receive(_ event: PeripheralEvent) {
        mapper.apply(event, to: &state)
        if state.activity.count > 150 { state.activity.removeFirst(state.activity.count - 150) }
    }
}
