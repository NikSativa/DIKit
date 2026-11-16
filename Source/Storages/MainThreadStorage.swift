import Foundation
import Threading

final class MainThreadStorage: Storage {
    private let storage: Storage

    var accessLevel: Options.AccessLevel {
        return storage.accessLevel
    }

    init(storage: Storage) {
        self.storage = storage
    }

    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity {
        let usendable = Queue.isolatedMain.sync {
            let resolved = storage.resolve(with: resolver, arguments: arguments)
            return USendable(resolved)
        }
        return usendable.value
    }
}

extension MainThreadStorage: @unchecked Sendable {}
