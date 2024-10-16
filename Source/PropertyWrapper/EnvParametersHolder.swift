#if canImport(SwiftUI)
import Foundation

@MainActor
internal final class EnvParametersHolder {
    var name: String?
    var arguments: Arguments?

    func cleanup() {
        name = nil
        arguments = nil
    }
}
#endif
