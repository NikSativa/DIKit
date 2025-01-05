import Foundation

public enum InjectSettings {
    #if swift(>=6.0)
    /// General container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public internal(set) nonisolated(unsafe) static var container: Container? {
        didSet {
            assert(oldValue == nil, "Container is already registered")
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
    #else
    /// General container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public internal(set) static var container: Container? {
        didSet {
            assert(oldValue == nil, "Container is already registered")
        }
    }

    /// Default setting for ```DIObservedObject``` property wrapper
    /// - Warning:  override it on your own risk
    public static var shouldCleanupObservedObject: Bool = false
    /// Default setting for ```DIState``` property wrapper
    /// - Warning:  override it on your own risk
    public static var shouldCleanupState: Bool = false
    /// Default setting for ```DIStateObject``` property wrapper
    /// - Warning:  override it on your own risk
    public static var shouldCleanupStateObject: Bool = false
    #endif

    /// Resolver for the container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public static var resolver: Resolver? {
        return container
    }
}
