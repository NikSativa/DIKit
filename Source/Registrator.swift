import Foundation

@MainActor
public protocol Registrator {
    /// register classes
    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options,
                     entity: @MainActor @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding

    func registration<T>(for type: T.Type,
                         name: String?) -> Forwarding
}

@MainActor
public extension Registrator {
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @MainActor @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return register(type,
                        options: options,
                        entity: entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @MainActor @escaping (_ resolver: Resolver) -> T) -> Forwarding {
        return register(type,
                        options: options,
                        entity: { resolver, _ in
                            return entity(resolver)
                        })
    }

    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @MainActor @escaping () -> T) -> Forwarding {
        return register(type,
                        options: options,
                        entity: { _, _ in
                            return entity()
                        })
    }

    func registration<T>(for type: T.Type = T.self,
                         name: String? = nil) -> Forwarding {
        return registration(for: type,
                            name: name)
    }
}
