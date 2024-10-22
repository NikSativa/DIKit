import Foundation

/// Options for the registration of the dependency.
@MainActor
public struct Options: Equatable {
    /// Access level for the dependency.
    /// - final: Dependency is final and can't be overridden.
    /// - open: Dependency is open and can be overridden in the future.
    public enum AccessLevel: Equatable {
        /// Dependency is final and can't be overridden.
        case final
        /// Dependency is open and can be overridden in the future.
        case open

        /// Forwarding access level. It is used as the default access level for the forwarding mechanism..
        public static let forwarding: AccessLevel = .final
        /// Default access level. It is used as the default access level for any dependency.
        public static let `default`: AccessLevel = .final
    }

    /// Entity kind for the dependency is about memory management for the dependency. It is used to determine the lifetime of the dependency.
    /// - container: Dependency is stored in the container and is shared between all dependencies. It is used as a singleton in the container.
    /// - weak: Dependency is stored in the container and is weakly referenced. It is shared between all dependencies while it is alive.
    /// - transient: Dependency is NOT stored in the container and is not shared between all dependencies. It is created each time it is resolved.
    public enum EntityKind: Equatable {
        /// Dependency is stored in the container and is shared between all dependencies. It is used as a singleton in the container.
        case container
        /// Dependency is stored in the container and is weakly referenced. It is shared between all dependencies while it is alive.
        case weak
        /// Dependency is NOT stored in the container and is not shared between all dependencies. It is created each time it is resolved.
        case transient

        /// Default memory management for the dependency. It is used as the default memory management for any dependency.
        public static let `default`: EntityKind = .weak
    }

    /// Default options for the dependency. It is used as the default options for any dependency.
    /// - accessLevel: default (aka final)
    /// - entityKind: default (aka weak)
    public static let `default`: Options = .init(accessLevel: .default, entityKind: .default)

    /// `container` options for the dependency. It is used as a singleton in the container.
    /// - accessLevel: default (aka final)
    /// - entityKind: default (aka container)
    public static let container: Options = .init(accessLevel: .default, entityKind: .container)

    /// `weak` options for the dependency. It is used as a singleton in the container.
    /// - accessLevel: default (aka final)
    /// - entityKind: default (aka weak)
    public static let weak: Options = .init(accessLevel: .default, entityKind: .weak)

    /// `transient` options for the dependency. It is used as a singleton in the container.
    /// - accessLevel: default (aka final)
    /// - entityKind: default (aka transient)
    public static let transient: Options = .init(accessLevel: .default, entityKind: .transient)

    /// Name for the dependency. It is used to resolve the dependency by the name.
    ///
    /// - Example
    ///
    /// you can register the dependency by the name multiple times:
    /// ```swift
    /// registrator.register(Manager.self, options: .named("admin")) {
    ///     return ManagerImpl()
    /// }
    ///
    /// registrator.register(Manager.self, options: .named("guest")) {
    ///     return ManagerImpl()
    /// }
    /// .implements(AnonymousService.self, named: "anonymous") // <-- forwards the dependency by the name
    /// ```
    ///
    /// and then resolve it by the name:
    ///
    /// ```swift
    /// registrator.register(Service.self, options: .container) { resolver in
    ///     return ServiceImpl(manager: resolver.resolve(named: "admin"))
    /// }
    /// ```
    public static func named(_ name: String) -> Options {
        return .init(accessLevel: .default, entityKind: .default, name: name)
    }

    /// Access level for the dependency.
    public let accessLevel: AccessLevel
    /// Entity kind for the dependency. It is about memory management for the dependency.
    public let entityKind: EntityKind
    /// Name for the dependency. It is used to resolve the dependency by the name.
    public let name: String?

    /// Creates options for the dependency. It is used to register the dependency with the specified options.
    /// - Parameters:
    ///  - accessLevel: Access level for the dependency. Default value is `final`.
    ///  - entityKind: Entity kind for the dependency. Default value is `weak`.
    ///  - name: Name for the dependency. Default value is `nil`.
    public init(accessLevel: AccessLevel = .default,
                entityKind: EntityKind = .default,
                name: String? = nil) {
        self.accessLevel = accessLevel
        self.entityKind = entityKind
        self.name = name
    }
}

// Changes the entity kind in the options.

/// - Example
/// ```swift
/// registrator.register(Service.self, options: .named("guest") + .weak) { resolver in
///     return ServiceImpl()
/// }
/// ```
@MainActor
public func +(lhs: Options, rhs: Options.EntityKind) -> Options {
    return .init(accessLevel: lhs.accessLevel, entityKind: rhs, name: lhs.name)
}

/// Changes the access level in the options.
///
/// - Example
/// ```swift
/// registrator.register(Service.self, options: .named("guest") + .open) { resolver in
///     return ServiceImpl()
/// }
/// ```
@MainActor
public func +(lhs: Options, rhs: Options.AccessLevel) -> Options {
    return .init(accessLevel: rhs, entityKind: lhs.entityKind, name: lhs.name)
}

/// Changes the dependency name in the options.
///
/// - Example
/// ```swift
/// registrator.register(Service.self, options: .container + "guest") { resolver in
///     return ServiceImpl()
/// }
/// ```
@MainActor
public func +(lhs: Options, rhs: String) -> Options {
    return .init(accessLevel: lhs.accessLevel, entityKind: lhs.entityKind, name: rhs)
}

#if swift(>=6.0)
extension Options: Sendable {}
extension Options.AccessLevel: Sendable {}
extension Options.EntityKind: Sendable {}
#endif
