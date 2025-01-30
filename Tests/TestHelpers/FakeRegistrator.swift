import DIKit
import Foundation
import SpryKit

final class FakeRegistrator: Registrator, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case register = "register(type:options:entity:)"
        case registration = "registration(forType:name:)"
    }

    init() {}

    @discardableResult
    func register<T>(type: T.Type, options: Options, entity: @MainActor @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return spryify(arguments: T.self, options, entity)
    }

    func registration<T>(forType type: T.Type, name: String?) -> Forwarding {
        return spryify(arguments: type, name)
    }
}
