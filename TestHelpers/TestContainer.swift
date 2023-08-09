import Foundation
import NInject
import NSpry

#if os(iOS)
import UIKit
#endif

@testable import NInject

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
    func register(_ type: (some Any).Type, named: String?, storage: Storage) {
        registered.append(.forwardingName(to: type, name: named, accessLevel: storage.accessLevel))
    }

    func registerAny(_ type: (some Any).Type, named: String?, storage: Storage) {
        registered.append(.forwardingName(to: type, name: named, accessLevel: storage.accessLevel))
    }
}

// MARK: - Registrator

extension TestRegistrator: Registrator {
    func registration(for type: (some Any).Type, name: String?) -> NInject.Forwarding {
        fatalError()
    }

    @discardableResult
    func register<T>(_ type: T.Type, options: Options, entity: @escaping (Resolver, Arguments) -> T) -> Forwarding {
        registered.append(.register(type, options))
        return Forwarder(container: self, storage: TransientStorage(accessLevel: options.accessLevel, generator: entity))
    }
}
