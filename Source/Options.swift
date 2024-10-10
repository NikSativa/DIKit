import Foundation

@MainActor
public struct Options: Equatable {
    public enum AccessLevel: Equatable {
        case final
        case open

        public static let forwarding: AccessLevel = .final
        public static let `default`: AccessLevel = .final
    }

    public enum EntityKind: Equatable {
        case container
        case weak
        case transient

        public static let `default`: EntityKind = .weak
    }

    public static let `default`: Options = .init(accessLevel: .default, entityKind: .default)

    public static let container: Options = .init(accessLevel: .default, entityKind: .container)
    public static let weak: Options = .init(accessLevel: .default, entityKind: .weak)
    public static let transient: Options = .init(accessLevel: .default, entityKind: .transient)

    public static func named(_ name: String) -> Options {
        return .init(accessLevel: .default, entityKind: .default, name: name)
    }

    public let accessLevel: AccessLevel
    public let entityKind: EntityKind
    public let name: String?

    @MainActor
    public init(accessLevel: AccessLevel = .final,
                entityKind: EntityKind = .weak,
                name: String? = nil) {
        self.accessLevel = accessLevel
        self.entityKind = entityKind
        self.name = name
    }
}

@MainActor
public func +(lhs: Options, rhs: Options.EntityKind) -> Options {
    return .init(accessLevel: lhs.accessLevel, entityKind: rhs, name: lhs.name)
}

@MainActor
public func +(lhs: Options, rhs: Options.AccessLevel) -> Options {
    return .init(accessLevel: rhs, entityKind: lhs.entityKind, name: lhs.name)
}

@MainActor
public func +(lhs: Options, rhs: String) -> Options {
    return .init(accessLevel: lhs.accessLevel, entityKind: lhs.entityKind, name: rhs)
}

#if swift(>=6.0)
extension Options: Sendable {}
extension Options.AccessLevel: Sendable {}
extension Options.EntityKind: Sendable {}
#endif
