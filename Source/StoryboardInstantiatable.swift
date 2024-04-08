import Foundation
import ObjectiveC

public protocol StoryboardSelfInjectable {
    func resolveDependncies(with resolver: Resolver)
}

public protocol SelfInjectable {
    func isDependenciesInitializationNeeded() -> Bool
    func resolveDependencies()
}

public extension SelfInjectable {
    func resolveDependencies() {
        if isDependenciesInitializationNeeded(),
           let container = InjectSettings.container {
            if let storyboardable = self as? StoryboardSelfInjectable {
                storyboardable.resolveDependncies(with: container)
            }
        }
    }
}

// MARK: - NSObject + SelfInjectable

extension NSObject: SelfInjectable {
    private enum AssociatedKeys {
        static let initialization: StaticString = "DIKit.isInitializedFromDI"
        static let dipTag: StaticString = "DIKit.dipTag"
    }

    @objc
    internal var isInitializedFromDI: Bool {
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
    internal private(set) var dipTag: String? {
        get {
            withUnsafePointer(to: AssociatedKeys.dipTag) { key in
                var key = key
                return objc_getAssociatedObject(self, &key) as? String
            }
        }
        set {
            withUnsafePointer(to: AssociatedKeys.dipTag) { key in
                var key = key
                objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            resolveDependencies()
        }
    }

    public func isDependenciesInitializationNeeded() -> Bool {
        defer {
            isInitializedFromDI = true
        }
        return !isInitializedFromDI
    }
}
