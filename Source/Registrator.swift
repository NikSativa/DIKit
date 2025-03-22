import Foundation

/// Registrator is a protocol for registering classes in the container.
///
/// - Important: Registration order is important
public protocol Registrator {
    /// Register a dependency in the container. The entity is created lazily
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency.
    ///   - entity: Entity for the dependency.
    /// - Returns: Forwarding for the dependency.
    ///
    /// See **`Forwarding`** protocol for more details.
    @discardableResult
    func register<T>(type: T.Type, options: Options, entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding

    /// Find a registration of the dependency in the container.
    /// It is useful when you want to use a type that is already registered in the container to expose it as another type.
    ///
    /// See **`Forwarding`** protocol for more details.
    ///
    /// - Important: Registration order is important
    func registration<T>(forType type: T.Type, name: String?) -> Forwarding
}

public extension Registrator {
    /// Register a dependency in the container. The entity is created lazily
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (aka `weak`&`final`).
    ///   - entity: Entity for the dependency.
    /// - Returns: Forwarding for the dependency. See **`Forwarding`** protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return register(type: type, options: options, entity: entity)
    }

    /// Register a dependency in the container. The entity is created lazily
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (aka `weak`&`final`).
    ///   - entity: Entity for the dependency.
    /// - Returns: Forwarding for the dependency. See **`Forwarding`** protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @escaping (_ resolver: Resolver) -> T) -> Forwarding {
        return register(type: type,
                        options: options,
                        entity: { resolver, _ in
                            return entity(resolver)
                        })
    }

    /// Register a dependency in the container. The entity is created lazily
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (aka `weak`&`final`).
    ///   - entity: Entity for the dependency.
    /// - Returns: Forwarding for the dependency. See **`Forwarding`** protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @escaping () -> T) -> Forwarding {
        return register(type: type,
                        options: options,
                        entity: { _, _ in
                            return entity()
                        })
    }

    /// Find a registration of the dependency in the container.
    /// It is useful when you want to use a type that is already registered in the container to expose it as another type.
    ///
    /// See **`Forwarding`** protocol for more details.
    ///
    /// - Important: Registration order is important
    func registration<T>(for type: T.Type = T.self, name: String? = nil) -> Forwarding {
        return registration(forType: type, name: name)
    }
}
