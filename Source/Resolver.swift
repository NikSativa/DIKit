import Foundation

public protocol Resolver {
    func optionalResolve<T>(_ type: T.Type, named: String?, with arguments: Arguments) -> T?
}

public extension Resolver {
    func resolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments = .init()) -> T {
        if let value = optionalResolve(type, named: named, with: arguments) {
            return value
        }
        fatalError("can't resolve dependency of <\(type)>")
    }

    func optionalResolve<T>(_ type: T.Type = T.self, with arguments: Arguments) -> T? {
        return optionalResolve(type, named: nil, with: arguments)
    }

    func optionalResolve<T>(_ type: T.Type = T.self, named: String? = nil) -> T? {
        return optionalResolve(type, named: named, with: .init())
    }

    func resolveWrapped<W: InstanceWrapper, T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments = .init()) -> W
    where W.Wrapped == T {
        return W.init {
            return self.resolve(type, named: named, with: arguments)
        }
    }
}
