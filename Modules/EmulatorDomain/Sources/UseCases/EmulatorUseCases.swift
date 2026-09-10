import Foundation

@MainActor public struct EmulatorUseCases {
    private let repository: any EmulatorRepository
    public init(repository: any EmulatorRepository) { self.repository = repository }
    public var current: EmulatorSnapshot { repository.snapshot }
    public func observe() -> AsyncStream<EmulatorSnapshot> { repository.observe() }
    public func execute(_ command: EmulatorCommand) throws { try repository.execute(command) }
}
