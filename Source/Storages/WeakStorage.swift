import Foundation

final class WeakStorage: Storage {
    private let creationLock = CreationLock()
    private weak var entity: AnyObject?
    private var creationArguments: Arguments?
    private let generator: Generator
    let accessLevel: Options.AccessLevel

    init(accessLevel: Options.AccessLevel,
         generator: @escaping Generator) {
        self.accessLevel = accessLevel
        self.generator = generator
    }

    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity {
        return creationLock.resolve(cached: {
            return entity
        }, create: {
            let usedArguments = creationArguments ?? arguments
            creationArguments = usedArguments
            return generator(resolver, usedArguments)
        }, store: { created in
            creationArguments = nil
            if let entity {
                return entity
            }
            entity = created as AnyObject
            return created
        })
    }

    func cachedEntity() -> Entity? {
        return creationLock.cachedValue {
            return entity
        }
    }
}
