import ProtocolCore

@MainActor
public protocol PeripheralServing: AnyObject {
    func start(security: LinkSecurity)
    func stop()
    func publishTelemetry()
}
