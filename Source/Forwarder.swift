import Foundation

@MainActor
public protocol Forwarding {
    @discardableResult
    func implements<T>(_ type: T.Type, named: String?, accessLevel: Options.AccessLevel?) -> Self
}

public extension Forwarding {
    @discardableResult
    func implements<T>(_ type: T.Type = T.self, named: String? = nil, accessLevel: Options.AccessLevel? = nil) -> Self {
        return implements(type, named: named, accessLevel: accessLevel)
    }
}

@MainActor
protocol ForwardRegistrator: AnyObject {
    func register<T>(_ type: T.Type, named: String?, storage: Storage)
}

@MainActor
struct Forwarder: Forwarding {
    private unowned let container: ForwardRegistrator
    private let storage: Storage

    @MainActor
    init(container: ForwardRegistrator,
         storage: Storage) {
        self.container = container
        self.storage = storage
    }

    @discardableResult
    func implements<T>(_ type: T.Type, named: String?, accessLevel: Options.AccessLevel?) -> Self {
        container.register(type, named: named, storage: ForwardingStorage(storage: storage, accessLevel: accessLevel))
        return self
    }
}
