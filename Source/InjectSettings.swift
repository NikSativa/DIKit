import Foundation

public enum InjectSettings {
    public internal(set) static var container: Container? {
        didSet {
            assert(oldValue == nil, "Container is already registered")
        }
    }

    public static var resolver: Resolver? {
        return container
    }
}
