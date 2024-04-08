import DIKit
import Foundation
import SpryKit

final class FakeResolver: Resolver, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case resolveWithTypeAndArguments = "resolve(_:with:)"
        case resolveWithType = "resolve(_:)"
        case resolveWithArguments = "resolve(with:)"

        case resolve = "resolve()"

        case resolveWithTypeAndNameAndArguments = "resolve(_:named:with:)"
        case resolveWithTypeAndName = "resolve(_:named:)"
        case resolveWithNameAndArguments = "resolve(named:with:)"

        case optionalResolveWithTypeAndArguments = "optionalResolve(_:with:)"
        case optionalResolveWithType = "optionalResolve(_:)"
        case optionalResolveWithArguments = "optionalResolve(with:)"

        case optionalResolve = "optionalResolve()"

        case optionalResolveWithTypeAndNameAndArguments = "optionalResolve(_:named:with:)"
        case optionalResolveWithTypeAndName = "optionalResolve(_:named:)"
        case optionalResolveWithNameAndArguments = "optionalResolve(named:with:)"
    }

    init() {}

    func resolve<T>(_ type: T.Type) -> T {
        return spryify(arguments: type)
    }

    func resolve<T>(with arguments: Arguments) -> T {
        return spryify(arguments: arguments)
    }

    func resolve<T>() -> T {
        return spryify()
    }

    func resolve<T>(_ type: T.Type, with arguments: Arguments) -> T {
        return spryify(arguments: type, arguments)
    }

    func resolve<T>(_ type: T.Type, named: String) -> T {
        return spryify(arguments: type, named)
    }

    func resolve<T>(named: String, with arguments: Arguments) -> T {
        return spryify(arguments: named, arguments)
    }

    func resolve<T>(named: String) -> T {
        return spryify(arguments: named)
    }

    func resolve<T>(_ type: T.Type, named: String, with arguments: Arguments) -> T {
        return spryify(arguments: type, named, arguments)
    }

    /// optional
    func optionalResolve<T>(_ type: T.Type, with arguments: Arguments) -> T? {
        return spryify(arguments: type, arguments)
    }

    func optionalResolve<T>(_ type: T.Type) -> T? {
        return spryify(arguments: type)
    }

    func optionalResolve<T>(with arguments: Arguments) -> T? {
        return spryify(arguments: arguments)
    }

    func optionalResolve<T>() -> T? {
        return spryify()
    }

    func optionalResolve<T>(_ type: T.Type, named: String?, with arguments: Arguments) -> T? {
        return spryify(arguments: type, named, arguments)
    }

    func optionalResolve<T>(_ type: T.Type, named: String) -> T? {
        return spryify(arguments: type, named)
    }

    func optionalResolve<T>(named: String, with arguments: Arguments) -> T? {
        return spryify(arguments: named, arguments)
    }

    func optionalResolve<T>(named: String) -> T? {
        return spryify(arguments: named)
    }
}
