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

extension TestRegistrator: ForwardRegistrator {
    func register<T>(_ type: T.Type, named: String?, storage: Storage) {
        registered.append(.forwardingName(to: type, name: named, accessLevel: storage.accessLevel))
    }
}

extension TestRegistrator: Registrator {
    @discardableResult
    func register<T>(_ type: T.Type, options: Options, _ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding {
        registered.append(.register(type, options))
        return Forwarder(container: self, storage: TransientStorage(accessLevel: options.accessLevel, generator: entity))
    }

    func registerStoryboardable<T>(_ type: T.Type, _: @escaping (T, Resolver) -> Void) {
        registered.append(.registerStoryboardable(type))
    }

    #if os(iOS)
    func registerViewController<T: UIViewController>(_ type: T.Type, _: @escaping (T, Resolver) -> Void) {
        registered.append(.registerViewController(type))
    }
    #endif
}
