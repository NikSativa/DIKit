import Foundation

// Dependency Injection Registrator protocol and its convenience extensions.

/// Registrator is a protocol for registering classes in the container.
/// This protocol defines a DI container interface supporting lazy registration of dependencies.
///
/// - Warning: Registration order matters — dependencies must be registered before they can be resolved.
public protocol Registrator {
    #if swift(>=6.0)
    var isolatedMain: IsolatedMainRegistrator { get }
    #endif

    /// Register a dependency in the container. The entity is created lazily using the provided factory closure.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency.
    ///   - entity: Factory closure used to create the dependency.
    /// - Returns: Forwarding for the dependency.
    ///
    /// See `Forwarding` protocol for more details.
    @discardableResult
    func register<T>(type: T.Type, options: Options, entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding

    /// Find a registration of the dependency in the container.
    /// It is useful when you want to use a type that is already registered in the container to expose it as another type (alias).
    ///
    /// See `Forwarding` protocol for more details.
    ///
    /// - Warning: Registration order matters — dependencies must be registered before they can be resolved.
    func registration<T>(forType type: T.Type, name: String?) -> Forwarding
}

public extension Registrator {
    /// Register a dependency in the container. The entity is created lazily using the provided factory closure.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (which means `weak` & `final`).
    ///   - entity: Factory closure used to create the dependency.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return register(type: type, options: options, entity: entity)
    }

    /// Register a dependency in the container. The entity is created lazily using the provided factory closure.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (which means `weak` & `final`).
    ///   - entity: Factory closure used to create the dependency.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
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

    /// Register a dependency in the container. The entity is created lazily using the provided factory closure.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (which means `weak` & `final`).
    ///   - entity: Factory closure used to create the dependency.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
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
    /// It is useful when you want to use a type that is already registered in the container to expose it as another type (alias).
    ///
    /// See `Forwarding` protocol for more details.
    ///
    /// - Warning: Registration order matters — dependencies must be registered before they can be resolved.
    func registration<T>(for type: T.Type = T.self, name: String? = nil) -> Forwarding {
        return registration(forType: type, name: name)
    }
}
