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
        case register = "register(_:options:entity:)"
        case registration = "registration(for:name:)"
        case registerAny = "registerAny(_:name:accessLevel:entity:)"
        case registrationOfAny = "registrationOfAny(for:name:)"
    }

    init() {}

    // MARK: - AnyObject

    /// register classes
    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options,
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return spryify(arguments: type, options, entity)
    }

    func registration(for type: (some Any).Type,
                      name: String?) -> Forwarding {
        return spryify(arguments: type, name)
    }

    // MARK: - Any

    /// register structs/valueType
    @discardableResult
    func registerAny<T>(_ type: T.Type,
                        name: String?,
                        accessLevel: Options.AccessLevel,
                        entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return spryify(arguments: type, name, accessLevel, entity)
    }

    func registrationOfAny(for type: (some Any).Type,
                           name: String?) -> Forwarding {
        return spryify(arguments: type, name)
    }
}
