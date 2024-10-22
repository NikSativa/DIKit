import Foundation

/// Resolver for the container.
/// It is used to resolve dependencies in the application according to your requirements.
@MainActor
public protocol Resolver {
    /// Resolve a dependency in the container.
    /// The entity is created lazily if it is not created before, otherwise it uses the registration options.
    /// If the registration is not found then return nil.
    func optionalResolve<T>(type: T.Type, named: String?, with arguments: Arguments) -> T?
}

public extension Resolver {
    /// Resolve a dependency in the container.
    /// The entity is created lazily if it is not created before, otherwise it uses the registration options.
    /// If the registration is not found then throw a fatal error with a message.
    func resolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> T {
        if let value = optionalResolve(type: type, named: named, with: arguments ?? .init()) {
            return value
        }
        fatalError("can't resolve dependency of <\(type)>")
    }

    /// Resolve a dependency in the container.
    /// The entity is created lazily if it is not created before, otherwise it uses the registration options.
    /// If the registration is not found then return nil.
    func optionalResolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> T? {
        return optionalResolve(type: type, named: named, with: arguments ?? .init())
    }

    /// Resolve a wrapped dependency in the container.
    /// The entity is created lazily if it is not created before, otherwise it uses the registration options.
    /// If the registration is not found then throw a fatal error with a message.
    func resolveWrapped<W: InstanceWrapper, T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> W
    where W.Wrapped == T {
        return W.init {
            return self.resolve(type, named: named, with: arguments)
        }
    }
}
