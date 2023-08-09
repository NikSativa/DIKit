import Foundation

public protocol Registrator {
    // MARK: - AnyObject

    /// register classes
    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options,
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding

    func registration<T>(for type: T.Type,
                         name: String?) -> Forwarding

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
                     entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        assert(type is AnyObject.Type, "use it only for RefType")
        return register(type,
                        options: .default,
                        entity: entity)
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     entity: @escaping (Resolver) -> T) -> Forwarding {
        assert(type is AnyObject.Type, "use it only for RefType")
        return register(type,
                        options: .default) { r, _ in
            return entity(r)
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     entity: @escaping () -> T) -> Forwarding {
        assert(type is AnyObject.Type, "use it only for RefType")
        return register(type,
                        options: .default) { _, _ in
            return entity()
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping (Resolver) -> T) -> Forwarding {
        assert(type is AnyObject.Type, "use it only for RefType")
        return register(type,
                        options: options) { resolver, _ in
            return entity(resolver)
        }
    }

    @discardableResult
    func register<T>(_ type: T.Type,
                     options: Options = .default,
                     entity: @escaping () -> T) -> Forwarding {
        assert(type is AnyObject.Type, "use it only for RefType")
        return register(type,
                        options: options) { _, _ in
            return entity()
        }
    }

    func registration(for type: (some Any).Type) -> Forwarding {
        assert(type is AnyObject.Type, "use it only for RefType")
        return registration(for: type,
                            name: nil)
    }

    // MARK: - Any

    @discardableResult
    func registerAny<T>(_ type: T.Type,
                        name: String? = nil,
                        accessLevel: Options.AccessLevel = .default,
                        entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        assert(!(type is AnyObject.Type), "use it only for ValueType")
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
        assert(!(type is AnyObject.Type), "use it only for ValueType")
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
        assert(!(type is AnyObject.Type), "use it only for ValueType")
        return registerAny(type,
                           name: name,
                           accessLevel: accessLevel) { _, _ in
            return entity()
        }
    }

    func registrationOfAny(for type: (some Any).Type,
                           name: String? = nil) -> Forwarding {
        assert(!(type is AnyObject.Type), "use it only for ValueType")
        return registrationOfAny(for: type,
                                 name: name)
    }
}
