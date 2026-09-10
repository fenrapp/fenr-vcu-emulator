import Foundation

// Independent client wire contract from the pinned FENR protocol revision.
enum DashboardStartupFixture {
    static let requiredSamples: [(uuid: UUID, length: Int)] = [
        (UUID(uuidString: "00001002-5374-6172-4B20-467574757265")!, 18),
        (UUID(uuidString: "00002001-5374-6172-4B20-467574757265")!, 4),
        (UUID(uuidString: "00002004-5374-6172-4B20-467574757265")!, 1),
        (UUID(uuidString: "00002005-5374-6172-4B20-467574757265")!, 16),
        (UUID(uuidString: "00006004-5374-6172-4B20-467574757265")!, 6),
        (UUID(uuidString: "00004100-5374-6172-4B20-467574757265")!, 8)
    ]
    static let batteryParametersUUID = UUID(uuidString: "00006003-5374-6172-4B20-467574757265")!
}
