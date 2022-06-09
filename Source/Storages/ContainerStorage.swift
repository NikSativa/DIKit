import Foundation

final class ContainerStorage: Storage {
    private var entity: Entity?
    private let generator: Generator
    let accessLevel: Options.AccessLevel

    init(accessLevel: Options.AccessLevel,
         generator: @escaping Generator,
         entity _: Entity? = nil) {
        self.accessLevel = accessLevel
        self.generator = generator
    }

    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity {
        if let entity = entity {
            return entity
        }

        let entity = generator(resolver, arguments)
        self.entity = entity
        return entity
    }
}
