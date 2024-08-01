import DIKit
import Foundation

@testable import DIKit

public final class TestContainer {
    public let registered: [RegistrationInfo]

    public init(assemblies: [Assembly]) {
        let testRegistrator = TestRegistrator()
        for assemby in assemblies {
            assemby.assemble(with: testRegistrator)
        }

        self.registered = testRegistrator.registered
    }
}

private final class TestRegistrator {
    private(set) var registered: [RegistrationInfo] = []
}

// MARK: - ForwardRegistrator

extension TestRegistrator: ForwardRegistrator {
    func register<T>(_ type: T.Type, named: String?, storage: Storage) {
        registered.append(.forwardingName(to: type, name: named, accessLevel: storage.accessLevel))
    }
}

// MARK: - Registrator

extension TestRegistrator: Registrator {
    public func registration<T>(for type: T.Type,
                                name: String?) -> Forwarding {
        fatalError()
    }

    @discardableResult
    public func register<T>(_ type: T.Type,
                            options: Options,
                            entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        registered.append(.register(type, options))
        return Forwarder(container: self, storage: TransientStorage(accessLevel: options.accessLevel, generator: entity))
    }
}
