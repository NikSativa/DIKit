import Foundation

public enum InjectSettings {
    /// General container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public internal(set) nonisolated(unsafe) static var container: Container? {
        didSet {
            assert(oldValue == nil || container == nil, "Container is already registered")
        }
    }

    /// Default setting for ```DIObservedObject``` property wrapper
    /// - Warning:  override it on your own risk
    public nonisolated(unsafe) static var shouldCleanupObservedObject: Bool = false
    /// Default setting for ```DIState``` property wrapper
    /// - Warning:  override it on your own risk
    public nonisolated(unsafe) static var shouldCleanupState: Bool = false
    /// Default setting for ```DIStateObject``` property wrapper
    /// - Warning:  override it on your own risk
    public nonisolated(unsafe) static var shouldCleanupStateObject: Bool = false

    @TaskLocal
    package static var scopedResolver: (any Resolver)?

    /// Resolver used by the `Inject`, `InjectLazy`, `InjectProvider` and `InjectWrapped` property wrappers.
    ///
    /// Returns the resolver a test installed for the current task through `DIKitTesting` when there is one,
    /// otherwise the shared container. Make sure that you have called `container.makeShared()` before relying on the shared container.
    public static var resolver: Resolver? {
        return scopedResolver ?? container
    }
}
