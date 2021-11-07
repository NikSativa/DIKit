import Foundation

#if !SWIFT_PACKAGE
private final class BundleFinder {
}

extension Foundation.Bundle {
    static var module: Bundle = {
        Bundle(for: BundleFinder.self)
    }()
}
#endif
