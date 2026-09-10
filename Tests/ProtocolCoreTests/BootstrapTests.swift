import Testing
@testable import ProtocolCore

@Test func packageLoads() {
    #expect(String(describing: ProtocolCoreModule.self) == "ProtocolCoreModule")
}
