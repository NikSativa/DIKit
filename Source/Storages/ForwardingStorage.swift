import Foundation

final class ForwardingStorage: Storage {
    let accessLevel: Options.AccessLevel
    private let storage: Storage

    init(storage: Storage,
         accessLevel: Options.AccessLevel? = nil) {
        self.storage = storage
        self.accessLevel = accessLevel ?? .forwarding
    }

    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity {
        return storage.resolve(with: resolver, arguments: arguments)
    }
}
