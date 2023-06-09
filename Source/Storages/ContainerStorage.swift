import Foundation

final class ContainerStorage: Storage {
    private var entity: Any?
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
        self.entity = entity
        return entity
    }
}
