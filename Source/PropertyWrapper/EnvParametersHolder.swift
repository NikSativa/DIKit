#if canImport(SwiftUI)
import Foundation

@MainActor
internal final class EnvParametersHolder {
    var name: String?
    var arguments: Arguments?
    let shouldCleanup: Bool

    init(name: String? = nil, arguments: Arguments? = nil, shouldCleanup: Bool) {
        self.name = name
        self.arguments = arguments
        self.shouldCleanup = shouldCleanup
    }

    func cleanupIfNeeded() {
        if shouldCleanup {
            name = nil
            arguments = nil
        }
    }
}
#endif
