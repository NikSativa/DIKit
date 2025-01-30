import DIKit
import Foundation
import SpryKit

final class FakeResolver: Resolver, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case resolve = "resolve(type:named:with:)"
        case resolveWrapped = "resolveWrapped(_:named:with:)"
        case optionalResolve = "optionalResolve(_:named:with:)"
    }

    init() {}

    func optionalResolve<T>(type: T.Type, named: String?, with arguments: Arguments) -> T? {
        return spryify(arguments: type, named, arguments)
    }

    func resolve<T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> T {
        return spryify(arguments: type, named, arguments)
    }

    func resolveWrapped<W: InstanceWrapper, T>(_ type: T.Type = T.self, named: String? = nil, with arguments: Arguments? = nil) -> W
    where W.Wrapped == T {
        return spryify(arguments: type, named, arguments)
    }
}
