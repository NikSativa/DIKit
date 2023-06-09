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
        case registration = "registration(for:name:)"
    }

    init() {}

    @discardableResult
    func register<T>(_ type: T.Type, options: Options, _ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding
    where T: AnyObject {
        return spryify(arguments: type, options, entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type, _ entity: @escaping (Resolver, Arguments) -> T) -> Forwarding
    where T: AnyObject {
        return spryify(arguments: type, entity)
    }

    @discardableResult
    func register(options: Options, _ entity: @escaping (Resolver, Arguments) -> some AnyObject) -> Forwarding
    {
        return spryify(arguments: options, entity)
    }

    @discardableResult
    func register(_ entity: @escaping (Resolver, Arguments) -> some AnyObject) -> Forwarding {
        return spryify(arguments: entity)
    }

    func registration(for type: (some Any).Type, name: String?) -> NInject.Forwarding {
        return spryify(arguments: type, name)
    }
}
