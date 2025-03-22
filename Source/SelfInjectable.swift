#if os(iOS) && canImport(UIKit)
import Foundation

public protocol SelfInjectable {
    func resolveDependncies(with resolver: Resolver)
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
            return withUnsafePointer(to: AssociatedKeys.initialization) { key in
                var key = key
                return (objc_getAssociatedObject(self, &key) as? Bool) ?? false
            }
        }
        set {
            withUnsafePointer(to: AssociatedKeys.initialization) { key in
                var key = key
                objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    @objc
    private(set) var dipTag: String? {
        get {
            return withUnsafePointer(to: AssociatedKeys.dipTag) { key in
                var key = key
                return objc_getAssociatedObject(self, &key) as? String
            }
        }
        set {
            withUnsafePointer(to: AssociatedKeys.dipTag) { key in
                var key = key
                objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            if let container = InjectSettings.container {
                resolveDependnciesIfNeeded(with: container)
            }
        }
    }

    private func isDependenciesInitializationNeeded() -> Bool {
        defer {
            isInitializedFromDI = true
        }
        return !isInitializedFromDI
    }

    public func resolveDependnciesIfNeeded(with resolver: Resolver) {
        if isDependenciesInitializationNeeded(),
           let selfInjectable = self as? SelfInjectable {
            selfInjectable.resolveDependncies(with: resolver)
        }
    }
}
#else
public extension NSObjectProtocol {
    func resolveDependnciesIfNeeded(with resolver: Resolver) {
        if let selfInjectable = self as? SelfInjectable {
            selfInjectable.resolveDependncies(with: resolver)
        }
    }
}
#endif
#endif
