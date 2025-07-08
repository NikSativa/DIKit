import DIKit
import Foundation
import SpryKit

final class FakeRegistrator: Registrator, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        #if swift(>=6.0)
        case isolatedMain
        #endif
        case register = "register(type:options:entity:)"
        case registration = "registration(forType:name:)"
    }

    init() {}

    #if swift(>=6.0)
    var isolatedMain: IsolatedMainRegistrator {
        return spryify()
    }
    #endif

    @discardableResult
    func register<T>(type: T.Type, options: Options, entity: @escaping (_ resolver: Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return spryify(arguments: T.self, options, entity)
    }

    func registration<T>(forType type: T.Type, name: String?) -> Forwarding {
        return spryify(arguments: type, name)
    }
}
