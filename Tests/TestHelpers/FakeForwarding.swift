import DIKit
import Foundation
import SpryKit

final class FakeForwarding: Forwarding, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case implementsNamedAccessLevel = "implements(type:named:accessLevel:)"
    }

    init() {}

    @discardableResult
    func implements<T>(type: T.Type, named: String?, accessLevel: Options.AccessLevel?) -> Self {
        return spryify(arguments: type, named, accessLevel)
    }
}
