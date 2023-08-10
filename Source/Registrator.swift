import Foundation

public protocol Registrator {
    /// register classes
    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options,
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding

    func registration<T>(for type: T.Type,
                         name: String?) -> Forwarding
}

public extension Registrator {
    @discardableResult
    func register<T>(_ type: T.Type,
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return register(type,
                        options: .default,
                        entity: entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     entity: @escaping (Resolver) -> T) -> Forwarding {
        return register(type,
                        options: .default) { r, _ in
            return entity(r)
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     entity: @escaping () -> T) -> Forwarding {
        return register(type,
                        options: .default) { _, _ in
            return entity()
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping (Resolver) -> T) -> Forwarding {
        return register(type,
                        options: options) { resolver, _ in
            return entity(resolver)
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping () -> T) -> Forwarding {
        return register(type,
                        options: options) { _, _ in
            return entity()
        }
    }

    func registration(for type: (some Any).Type) -> Forwarding {
        return registration(for: type,
                            name: nil)
    }
}
