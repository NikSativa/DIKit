#if canImport(SwiftUI)
import Foundation
import SpryKit
import SwiftUI

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension ImageRenderer {
    @MainActor var actualImage: SpryKit.Image? {
        #if os(macOS)
        return nsImage
        #elseif os(iOS) || os(tvOS) || os(watchOS) || supportsVisionOS
        return uiImage
        #endif
    }
}
#endif
