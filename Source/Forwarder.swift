import Foundation

/// Protocol for Forwarding behavior
/// Forwarding is a mechanism that allows to forward a type to another type.
/// It is useful when you want to use a type that is already registered in the container to expose it as another type.
///
/// - Example:
///   When you have a protocol `Service` and a class `ServiceImp` that implements it.
///   You can register `ServiceImp` in the container and then forward it to `Service`.
///   So when you resolve `Service` you will get an instance of `ServiceImp`.
///
/// ```swift
/// registrator.register(ServiceImp.self, options: .transient) { resolver in
///    return ServiceImp()
/// }
/// .implements(Service.self)
/// ```
///
/// or you can redirect the type to another type from another assembly, but you must strictly ensure that the dependency is already registered in the container _(registration order is important)_.
///
/// ```swift
/// registrator.registration(for: BuildMode.self)
///    .implements(ApiBuildMode.self)
/// ```
public protocol Forwarding {
    /// Registers a type for forwarding with the specified name and access level.
    @discardableResult
    func implements<T>(type: T.Type, named: String?, accessLevel: Options.AccessLevel?) -> Self
}

public extension Forwarding {
    /// Registers a type for forwarding with the specified name and access level.
    ///
    /// - Example:
    /// ```swift
    /// registrator.register(Manager.self, options: .named("guest")) {
    ///     return ManagerImpl()
    /// }
    /// .implements(AnonymousService.self, named: "anonymous") // <-- forwards the dependency by the name
    /// ```
    @discardableResult
    func implements<T>(_ type: T.Type = T.self, named: String? = nil, accessLevel: Options.AccessLevel? = nil) -> Self {
        return implements(type: type, named: named, accessLevel: accessLevel)
    }
}

internal protocol ForwardRegistrator: AnyObject {
    func register<T>(_ type: T.Type, named: String?, storage: Storage)
}

internal struct Forwarder: Forwarding {
    private unowned let container: ForwardRegistrator
    private let storage: Storage

    init(container: ForwardRegistrator,
         storage: Storage) {
        self.container = container
        self.storage = storage
    }

    @discardableResult
    func implements<T>(type: T.Type, named: String?, accessLevel: Options.AccessLevel?) -> Self {
        container.register(type, named: named, storage: ForwardingStorage(storage: storage, accessLevel: accessLevel))
        return self
    }
}
