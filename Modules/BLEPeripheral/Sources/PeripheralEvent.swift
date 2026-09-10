import Foundation
import ProtocolEngine

public enum PeripheralEvent: Sendable {
    case stopped
    case waitingForBluetooth
    case advertising
    case bluetoothUnavailable
    case unauthorized
    case failure(PeripheralFailure)
    case session(SessionPhase)
    case transaction(operation: String, characteristic: UInt16, bytes: Int)
    case subscribed(UInt16, maximumBytes: Int)
    case unsubscribed(UInt16)
}

public enum PeripheralFailure: Sendable {
    case queueFull
    case payloadTooLarge
    case platform(domain: String, code: Int)
}
