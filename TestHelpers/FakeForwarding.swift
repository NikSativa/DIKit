import DIKit
import Foundation
import SpryKit

public final class FakeForwarding: Forwarding, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case implementsNamedAccessLevel = "implements(_:named:accessLevel:)"
    }

    public init() {}

    @discardableResult
    public func implements<T>(_ type: T.Type = T.self, named: String? = nil, accessLevel: Options.AccessLevel? = nil) -> Self {
        return spryify(arguments: type, named, accessLevel)
    }
}
