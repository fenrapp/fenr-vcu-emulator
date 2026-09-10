import Foundation
import BLEPeripheral

struct PeripheralEventMapper {
    func apply(_ event: PeripheralEvent, to state: inout EmulatorViewState) {
        let detail: String
        switch event {
        case .stopped:
            state.running = false
            state.transport = String(localized: "Stopped")
            state.authentication = String(localized: "No authenticated session")
            detail = state.transport
        case .waitingForBluetooth:
            state.running = true
            state.transport = String(localized: "Starting Bluetooth")
            detail = state.transport
        case .advertising:
            state.transport = String(localized: "Advertising")
            detail = state.transport
        case .bluetoothUnavailable:
            state.transport = String(localized: "Bluetooth unavailable")
            state.authentication = String(localized: "No authenticated session")
            detail = state.transport
        case .unauthorized:
            state.transport = String(localized: "Bluetooth permission required")
            detail = state.transport
        case .failure(let message):
            state.transport = String(localized: "Peripheral error")
            detail = message
        case .session(let phase):
            switch phase {
            case .idle: state.authentication = String(localized: "No authenticated session")
            case .challenged: state.authentication = String(localized: "Waiting for V2 response")
            case .authenticated: state.authentication = String(localized: "V2 authenticated")
            }
            return
        case .transaction(let operation, let characteristic, let bytes):
            detail = String(format: "%@ %04X (%d bytes)", operation, characteristic, bytes)
        case .subscribed(let characteristic, let maximumBytes):
            detail = String(format: "subscribe %04X (max %d bytes)", characteristic, maximumBytes)
        case .unsubscribed(let characteristic):
            detail = String(format: "unsubscribe %04X", characteristic)
        }
        state.activity.append(ActivityRow(time: Date.now.formatted(date: .omitted, time: .standard), detail: detail))
    }
}
