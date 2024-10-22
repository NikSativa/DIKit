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
    #else
    /// General container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public internal(set) static var container: Container? {
        didSet {
            assert(oldValue == nil, "Container is already registered")
        }
    }
    #endif

    /// Resolver for the container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public static var resolver: Resolver? {
        return container
    }
}
