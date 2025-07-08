#if swift(>=6.0)
import Foundation
import Threading

/// A protocol for registering dependencies in a container that guarantees
/// main-actor execution for factory closures.
///
/// Use this when the dependencies you register (like UI components) must be
/// created on the main thread. All closures passed to `register(...)` must
/// be `@MainActor` isolated.
///
/// - Important: The order of registration matters — dependencies must be registered before being resolved.
/// - SeeAlso: `Forwarding` for how registered values are exposed or transformed.
public protocol IsolatedMainRegistrator {
    /// Register a dependency in the container. The entity is created lazily
    /// on the main actor.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency.
    ///   - entity: Main-actor-isolated factory closure.
    /// - Returns: Forwarding for the dependency.
    @discardableResult
    func register<T>(type: T.Type, options: Options, entity: @MainActor @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding

    /// Find a registration of the dependency in the container.
    /// Useful when exposing a registered type as another type.
    ///
    /// - Parameters:
    ///   - type: The type to retrieve.
    ///   - name: Optional registration name.
    /// - Returns: Forwarding for the dependency.
    func registration<T>(forType type: T.Type, name: String?) -> Forwarding
}

public extension IsolatedMainRegistrator {
    /// Register a dependency in the container. The entity is created lazily on the main actor.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (which means `weak` & `final`).
    ///   - entity: Main-actor-isolated factory closure for the dependency.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @MainActor @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return register(type: type, options: options, entity: entity)
    }

    /// Register a dependency in the container. The entity is created lazily on the main actor.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (which means `weak` & `final`).
    ///   - entity: Main-actor-isolated factory closure for the dependency.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @MainActor @escaping (_ resolver: Resolver) -> T) -> Forwarding {
        return register(type: type,
                        options: options,
                        entity: { resolver, _ in
                            return entity(resolver)
                        })
    }

    /// Register a dependency in the container. The entity is created lazily on the main actor.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency.
    ///   - options: Options for the dependency. Default value is `.default` (which means `weak` & `final`).
    ///   - entity: Main-actor-isolated factory closure for the dependency.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
    @discardableResult
    func register<T>(_ type: T.Type = T.self,
                     options: Options = .default,
                     entity: @MainActor @escaping () -> T) -> Forwarding {
        return register(type: type,
                        options: options,
                        entity: { _, _ in
                            return entity()
                        })
    }

    /// Find a registration of the dependency in the container.
    /// It is useful when you want to use a type that is already registered in the container to expose it as another type.
    ///
    /// - Parameters:
    ///   - type: Type of the dependency to look up. Default is the type inferred from the generic parameter `T`.
    ///   - name: Optional registration name.
    /// - Returns: Forwarding for the dependency. See `Forwarding` protocol for more details.
    ///
    /// - Warning: The order of registration matters: dependencies must be registered before being resolved.
    func registration<T>(for type: T.Type = T.self, name: String? = nil) -> Forwarding {
        return registration(forType: type, name: name)
    }
}
#endif
