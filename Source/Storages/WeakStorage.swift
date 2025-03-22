import Foundation

final class WeakStorage: Storage {
    private weak var entity: AnyObject?
    private let generator: Generator
    let accessLevel: Options.AccessLevel

    init(accessLevel: Options.AccessLevel,
         generator: @escaping Generator) {
        self.accessLevel = accessLevel
        self.generator = generator
    }

    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity {
        if let entity {
            return entity
        }

        let entity = generator(resolver, arguments)
        self.entity = entity as AnyObject
        return entity
    }
}
