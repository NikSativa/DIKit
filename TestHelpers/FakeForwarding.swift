import Foundation
import NSpry

import NInject

final class FakeForwarding: Forwarding, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case implements = "implements(_:)"
        case implementsNamed = "implements(_:named:)"
        case implementsAccessLevel = "implements(_:accessLevel:)"
        case implementsNamedAccessLevel = "implements(_:named:accessLevel:)"
    }

    init() {}

    func implements<T>(_ type: T.Type) -> Self {
        return spryify(arguments: type)
    }

    func implements<T>(_ type: T.Type, named: String) -> Self {
        return spryify(arguments: type, named)
    }

    func implements<T>(_ type: T.Type, accessLevel: Options.AccessLevel) -> Self {
        return spryify(arguments: type, accessLevel)
    }

    func implements<T>(_ type: T.Type, named: String, accessLevel: Options.AccessLevel) -> Self {
        return spryify(arguments: type, named, accessLevel)
    }
}
