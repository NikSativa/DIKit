import Foundation

protocol Storage {
    typealias Entity = Any
    typealias Generator = (Resolver, _ arguments: Arguments) -> Entity

    var accessLevel: Options.AccessLevel { get }
    func resolve(with resolver: Resolver, arguments: Arguments) -> Entity
}
