import DIKit
import Foundation

@testable import DIKit

@MainActor
final class TestContainer {
    let registered: [RegistrationInfo]

    init(assemblies: [Assembly]) {
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
    func registration<T>(forType type: T.Type, name: String?) -> Forwarding {
        fatalError()
    }

    @discardableResult
    func register<T>(type: T.Type, options: Options, entity: @MainActor @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        registered.append(.register(type, options))
        return Forwarder(container: self, storage: TransientStorage(accessLevel: options.accessLevel, generator: entity))
    }
}
