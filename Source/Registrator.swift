import Foundation

public protocol Registrator {
    // MARK: - AnyObject

    /// register classes
    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options,
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding
        where T: AnyObject

    func registration<T>(for type: T.Type,
                         name: String?) -> Forwarding
        where T: AnyObject

    // MARK: - Any

    /// register structs/valueType
    @discardableResult
    func registerAny<T>(_ type: T.Type,
                        name: String?,
                        accessLevel: Options.AccessLevel,
                        entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding

    func registrationOfAny<T>(for type: T.Type,
                              name: String?) -> Forwarding
}

public extension Registrator {
    // MARK: - AnyObject

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding
    where T: AnyObject {
        return register(type,
                        options: options,
                        entity: entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping (Resolver) -> T) -> Forwarding
    where T: AnyObject {
        return register(type,
                        options: options) { r, _ in
            return entity(r)
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping () -> T) -> Forwarding
    where T: AnyObject {
        return register(type,
                        options: options) { _, _ in
            return entity()
        }
    }

    func registration(for type: (some AnyObject).Type, name: String? = nil) -> Forwarding {
        return registration(for: type,
                            name: name)
    }

    // MARK: - Any

    @discardableResult
    func registerAny<T>(_ type: T.Type,
                        name: String? = nil,
                        accessLevel: Options.AccessLevel = .default,
                        entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        return registerAny(type,
                           name: name,
                           accessLevel: accessLevel,
                           entity: entity)
    }

    @discardableResult
    func registerAny<T>(_ type: T.Type,
                        name: String? = nil,
                        accessLevel: Options.AccessLevel = .default,
                        entity: @escaping (Resolver) -> T) -> Forwarding {
        return registerAny(type,
                           name: name,
                           accessLevel: accessLevel) { r, _ in
            return entity(r)
        }
    }

    @discardableResult
    func registerAny<T>(_ type: T.Type,
                        name: String? = nil,
                        accessLevel: Options.AccessLevel = .default,
                        entity: @escaping () -> T) -> Forwarding {
        return registerAny(type,
                           name: name,
                           accessLevel: accessLevel) { _, _ in
            return entity()
        }
    }

    func registrationOfAny(for type: (some Any).Type, name: String? = nil) -> Forwarding {
        return registrationOfAny(for: type,
                                 name: name)
    }
}
