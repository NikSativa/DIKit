import Foundation

public enum InjectSettings {
    internal static var container: Container? {
        didSet {
            assert(oldValue == nil)
        }
    }

    public static var resolver: Resolver? {
        return container
    }
}
