import DIKit
import Foundation
import SpryKit

public final class FakeRegistrator: Registrator, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case register = "register(_:options:entity:)"
        case registration = "registration(for:name:)"
    }

    public init() {}

    @discardableResult
    public func register<T>(_ type: T.Type,
                            options: Options,
                            entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return spryify(arguments: T.self, options, entity)
    }

    public func registration<T>(for type: T.Type,
                                name: String?) -> Forwarding {
        return spryify(arguments: type, name)
    }
}
