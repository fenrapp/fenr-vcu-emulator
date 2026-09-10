import Foundation
import ProtocolEngine

public enum PeripheralEvent: Sendable {
    case stopped
    case waitingForBluetooth
    case advertising
    case bluetoothUnavailable
    case unauthorized
    case failure(String)
    case session(SessionPhase)
    case transaction(operation: String, characteristic: UInt16, bytes: Int)
    case subscribed(UInt16, maximumBytes: Int)
    case unsubscribed(UInt16)
}
