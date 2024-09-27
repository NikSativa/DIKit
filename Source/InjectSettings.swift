import Foundation

public enum InjectSettings {
    #if swift(>=6.0)
    public internal(set) nonisolated(unsafe) static var container: Container? {
        didSet {
            assert(oldValue == nil, "Container is already registered")
        }
    }
    #else
    public internal(set) static var container: Container? {
        didSet {
            assert(oldValue == nil, "Container is already registered")
        }
    }
    #endif

    public static var resolver: Resolver? {
        return container
    }
}
