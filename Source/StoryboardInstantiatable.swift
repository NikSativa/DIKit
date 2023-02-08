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
            } else {
                container.resolveStoryboardable(self)
            }
        }
    }
}

// MARK: - NSObject + SelfInjectable

extension NSObject: SelfInjectable {
    private enum AssociatedKeys {
        static var initialization = "NInject.isInitializedFromDI"
        static var dipTag = "NInject.dipTag"
    }

    @objc
    internal var isInitializedFromDI: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.initialization) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.initialization, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc
    internal private(set) var dipTag: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.dipTag) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.dipTag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
