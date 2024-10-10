import Foundation

@MainActor
public final class ObservableResolver: Resolver, ObservableObject {
    private let original: Resolver

    init(_ original: Resolver) {
        self.original = original
    }

    public func optionalResolve<T>(_ type: T.Type, named: String?, with arguments: Arguments) -> T? {
        return original.optionalResolve(type, named: named, with: arguments)
    }
}

public extension Resolver {
    func toObservable() -> ObservableResolver {
        return ObservableResolver(self)
    }
}
