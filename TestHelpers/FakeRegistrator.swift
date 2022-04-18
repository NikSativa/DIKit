import Foundation
import NSpry

#if os(iOS)
import UIKit
#endif

import NInject

final class FakeRegistrator: Registrator, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case registerWithTypeAndOptions = "register(_:options:entity:)"
        case registerWithType = "register(_:entity:)"
        case registerWithOptions = "register(options:entity:)"
        case register = "register(entity:)"
        case registerStoryboardable = "registerStoryboardable(_:entity:)"
        #if os(iOS)
        case registerViewController = "registerViewController(_:entity:)"
        #endif
    }

    init() {}

    @discardableResult
    func register<T>(_ type: T.Type, options: Options, _ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding {
        return spryify(arguments: type, options, entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type, _ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding {
        return spryify(arguments: type, entity)
    }

    @discardableResult
    func register<T>(options: Options, _ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding {
        return spryify(arguments: options, entity)
    }

    @discardableResult
    func register<T>(_ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding {
        return spryify(arguments: entity)
    }

    func registerStoryboardable<T>(_ type: T.Type, _ entity: @escaping (T, Resolver) -> Void) {
        return spryify(arguments: type, entity)
    }

    #if os(iOS)
    func registerViewController<T: UIViewController>(_ type: T.Type, _ entity: @escaping (T, Resolver) -> Void) {
        return spryify(arguments: type, entity)
    }
    #endif
}
