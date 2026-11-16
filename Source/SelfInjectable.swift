#if os(iOS) && canImport(UIKit)
import Foundation

/// An object that resolves its own dependencies.
public protocol SelfInjectable {
    /// Resolves the dependencies of the object with the specified resolver.
    func resolveDependencies(with resolver: Resolver)

    @available(*, deprecated, renamed: "resolveDependencies(with:)")
    func resolveDependncies(with resolver: Resolver)
}

public extension SelfInjectable {
    @available(*, deprecated, message: "Implement resolveDependencies(with:)")
    func resolveDependencies(with resolver: Resolver) {
        resolveDependncies(with: resolver)
    }

    @available(*, deprecated, renamed: "resolveDependencies(with:)")
    func resolveDependncies(with resolver: Resolver) {
        assertionFailure("\(Self.self) does not implement resolveDependencies(with:)")
    }
}

#if canImport(ObjectiveC)
import ObjectiveC

extension NSObject {
    private enum AssociatedKeys {
        static let initialization: StaticString = "DIKit.isInitializedFromDI"
        static let dipTag: StaticString = "DIKit.dipTag"
    }

    @objc
    private var isInitializedFromDI: Bool {
        get {
            return (objc_getAssociatedObject(self, AssociatedKeys.initialization.utf8Start) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.initialization.utf8Start, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc
    private(set) var dipTag: String? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.dipTag.utf8Start) as? String
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.dipTag.utf8Start, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if let resolver = InjectSettings.resolver {
                resolveDependenciesIfNeeded(with: resolver)
            }
        }
    }

    private func isDependenciesInitializationNeeded() -> Bool {
        defer {
            isInitializedFromDI = true
        }
        return !isInitializedFromDI
    }

    /// Resolves the dependencies of a `SelfInjectable` object one time. Later calls do nothing.
    public func resolveDependenciesIfNeeded(with resolver: Resolver) {
        if isDependenciesInitializationNeeded(),
           let selfInjectable = self as? SelfInjectable {
            selfInjectable.resolveDependencies(with: resolver)
        }
    }

    @available(*, deprecated, renamed: "resolveDependenciesIfNeeded(with:)")
    public func resolveDependnciesIfNeeded(with resolver: Resolver) {
        resolveDependenciesIfNeeded(with: resolver)
    }
}
#else
public extension NSObjectProtocol {
    /// Resolves the dependencies of a `SelfInjectable` object.
    func resolveDependenciesIfNeeded(with resolver: Resolver) {
        if let selfInjectable = self as? SelfInjectable {
            selfInjectable.resolveDependencies(with: resolver)
        }
    }

    @available(*, deprecated, renamed: "resolveDependenciesIfNeeded(with:)")
    func resolveDependnciesIfNeeded(with resolver: Resolver) {
        resolveDependenciesIfNeeded(with: resolver)
    }
}
#endif
#endif
