import Foundation

@MainActor
public protocol Resolver {
    func optionalResolve<T>(_ type: T.Type, named: String?, with arguments: Arguments) -> T?
    func resolve<T>(_ type: T.Type, named: String?, with arguments: Arguments?) -> T
    func resolveWrapped<W: InstanceWrapper, T>(_ type: T.Type, named: String?, with arguments: Arguments?) -> W where W.Wrapped == T
}

public extension Resolver {
    func resolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> T {
        if let value = optionalResolve(type, named: named, with: arguments ?? .init()) {
            return value
        }
        fatalError("can't resolve dependency of <\(type)>")
    }

    func optionalResolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> T? {
        return optionalResolve(type, named: named, with: arguments ?? .init())
    }

    func resolveWrapped<W: InstanceWrapper, T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> W
    where W.Wrapped == T {
        return W.init {
            return self.resolve(type, named: named, with: arguments)
        }
    }
}
