import Foundation
import ObjectiveC

public protocol StoryboardSelfInjectable {
    func resolveDependncies(with resolver: Resolver)
}

extension NSObject {
    private enum AssociatedKeys {
        static var initialization = "NInject.isInitializedFromDI"
        static var container = "NInject.container"
        static var dipTag = "NInject.dipTag"
    }

    @objc internal var isInitializedFromDI: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.initialization) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.initialization, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc private static var containerHolder: ContainerPropertyHolder? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerPropertyHolder
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.container, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    internal static var container: Container? {
        get {
            return containerHolder?.value
        }
        set {
            containerHolder = newValue.map { ContainerPropertyHolder(value: $0) }
        }
    }

    @objc internal private(set) var dipTag: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.dipTag) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.dipTag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            resolveDependencies()
        }
    }

    public func resolveDependenciesManually() {
        resolveDependencies()
    }

    @available(*, deprecated, message: "Will be removed soon")
    public func resolveDependencies<T>(as type: T, name: String? = nil) {
        if isInitializationNeeded() {
            NSObject.container?.resolveStoryboardable(self, as: type, name: name)
        }
    }

    private func isInitializationNeeded() -> Bool {
        defer {
            isInitializedFromDI = true
        }
        return !isInitializedFromDI
    }

    private func resolveDependencies() {
        if isInitializationNeeded(),
           let container = NSObject.container {
            if let storyboardable = self as? StoryboardSelfInjectable {
                storyboardable.resolveDependncies(with: container)
            } else {
                container.resolveStoryboardable(self)
            }
        }
    }
}

private final class ContainerPropertyHolder: NSObject {
    weak var value: Container?

    required init(value: Container) {
        self.value = value
        super.init()
    }
}
