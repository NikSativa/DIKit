import DIKit
import Foundation
import SpryKit

public final class FakeResolver: Resolver, Spryable {
    public enum ClassFunction: String, StringRepresentable {
        case empty
    }

    public enum Function: String, StringRepresentable {
        case resolve = "resolve(_:named:with:)"
        case resolveWrapped = "resolveWrapped(_:named:with:)"
        case optionalResolve = "optionalResolve(_:named:with:)"
    }

    public init() {}

    public func optionalResolve<T>(_ type: T.Type, named: String?, with arguments: Arguments) -> T? {
        return spryify(arguments: type, named, arguments)
    }

    public func resolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> T {
        return spryify(arguments: type, named, arguments)
    }

    public func resolveWrapped<W: InstanceWrapper, T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> W
    where W.Wrapped == T {
        return spryify(arguments: type, named, arguments)
    }
}
