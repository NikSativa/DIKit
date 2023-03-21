import Foundation
import NInject
import NSpry

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

    func implements(_ type: (some Any).Type) -> Self {
        return spryify(arguments: type)
    }

    func implements(_ type: (some Any).Type, named: String) -> Self {
        return spryify(arguments: type, named)
    }

    func implements(_ type: (some Any).Type, accessLevel: Options.AccessLevel?) -> Self {
        return spryify(arguments: type, accessLevel)
    }

    func implements(_ type: (some Any).Type, named: String?, accessLevel: Options.AccessLevel?) -> Self {
        return spryify(arguments: type, named, accessLevel)
    }
}
