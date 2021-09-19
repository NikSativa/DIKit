import Foundation
import UIKit

public protocol Registrator {
    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options,
                     _ entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding

    func registration<T>(for type: T.Type,
                         name: String?) -> Forwarding

    @discardableResult
    func registerViewController<T: UIViewController>(_ type: T.Type,
                                                     options: Options,
                                                     _ entity: @escaping (Resolver, ViewControllerFactory) -> T) -> Forwarding

    func registerStoryboardable<T>(_ type: T.Type,
                                   _ entity: @escaping (T, Resolver) -> Void)
    func registerViewController<T: UIViewController>(_ type: T.Type,
                                                     _ entity: @escaping (T, Resolver) -> Void)
}

public extension Registrator {
    func registration<T>(for type: T.Type, name: String? = nil) -> Forwarding {
        return registration(for: type, name: name)
    }

    func registerViewController<T: UIViewController>(_ type: T.Type, _ entity: @escaping (T, Resolver) -> Void) {
        registerStoryboardable(type, entity)
    }

    func registerViewController<T>(_ type: T.Type) {
        registerStoryboardable(type) { _, _ in }
    }

    func registerStoryboardable<T>(_ type: T.Type) {
        registerStoryboardable(type) { _, _ in }
    }
}

public extension Registrator {
    @discardableResult
    func registerViewController<T: UIViewController>(_ type: T.Type,
                                                     options: Options = .transient,
                                                     _ entity: @escaping (Resolver, ViewControllerFactory) -> T) -> Forwarding {
        return register(type, options: options) { resolver, _ in
            let factory = resolver.resolve(ViewControllerFactory.self)
            let vc = entity(resolver, factory)
            return vc
        }
    }

    // MARK: resolver & arguments

    @discardableResult
    func register<T>(options: Options, _ entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        register(T.self, options: options, entity)
    }

    @discardableResult
    func register<T>(_ entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        register(T.self, options: .default, entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type, _ entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        register(type, options: .default, entity)
    }

    @discardableResult
    func register<T>(options: Options, _ entity: @escaping (_ arguments: Arguments) -> T) -> Forwarding {
        register(options: options) { _, args in entity(args) }
    }

    @discardableResult
    func register<T>(_ entity: @escaping (_ arguments: Arguments) -> T) -> Forwarding {
        register(options: .default) { _, args in entity(args) }
    }

    // MARK: resolver

    @discardableResult
    func register<T>(options: Options, _ entity: @escaping (Resolver) -> T) -> Forwarding {
        register(T.self, options: options) { r, _ in entity(r) }
    }

    @discardableResult
    func register<T>(_ entity: @escaping (Resolver) -> T) -> Forwarding {
        register(T.self, options: .default) { r, _ in entity(r) }
    }

    @discardableResult
    func register<T>(_ type: T.Type, _ entity: @escaping (Resolver) -> T) -> Forwarding {
        register(type, options: .default) { r, _ in entity(r) }
    }

    @discardableResult
    func register<T>(_ type: T.Type, options: Options, _ entity: @escaping (Resolver) -> T) -> Forwarding {
        register(type, options: options) { r, _ in entity(r) }
    }

    // MARK: -

    @discardableResult
    func register<T>(options: Options, _ entity: @escaping () -> T) -> Forwarding {
        register(options: options) { _, _ in entity() }
    }

    @discardableResult
    func register<T>(_ entity: @escaping () -> T) -> Forwarding {
        register(options: .default) { _, _ in entity() }
    }

    @discardableResult
    func register<T>(_: T.Type, options: Options, _ entity: @escaping () -> T) -> Forwarding {
        register(options: options) { _, _ in entity() }
    }

    @discardableResult
    func register<T>(_: T.Type, _ entity: @escaping () -> T) -> Forwarding {
        register(options: .default) { _, _ in entity() }
    }
}
