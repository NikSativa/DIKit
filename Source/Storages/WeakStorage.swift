import Foundation

final class WeakStorage: Storage {
    private var entity: () -> Entity?
    private let generator: Generator
    let accessLevel: Options.AccessLevel

    init(accessLevel: Options.AccessLevel,
         generator: @escaping Generator,
         entity: @escaping () -> Entity? = { nil }) {
        self.accessLevel = accessLevel
        self.generator = generator
        self.entity = entity
    }

    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity {
        if let entity = entity() {
            return entity
        }

        let entity = generator(resolver, arguments)
        if #available(iOS 13, *) {
            let wrapped = entity as AnyObject
            self.entity = { [weak wrapped] in
                return wrapped
            }
        } else {
            // iOS 12.4 has crash when eventually resolving code `entity as AnyObject` and return `nil`
            // while registered object is `struct` (not class)
            let wrapped = NSValue(nonretainedObject: entity)
            self.entity = { [weak wrapped] in
                var pointer: Entity?
                wrapped?.getValue(&pointer)
                return pointer
            }
        }

        return entity
    }
}
