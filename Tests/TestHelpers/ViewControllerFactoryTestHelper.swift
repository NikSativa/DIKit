#if os(iOS) && canImport(UIKit)
import Foundation
import UIKit

@testable import DIKit

enum ViewControllerFactoryTestHelper {
    @MainActor
    static func instantiate<T>(from nibName: String? = nil, bundle: Bundle? = nil, resolver: Resolver) -> T where T: UIViewController {
        return ViewControllerFactoryImpl(resolver: resolver).instantiate(from: nibName, bundle: bundle)
    }

    @MainActor
    static func createNavigationController<T, N>(from nibName: String? = nil, bundle: Bundle? = nil, resolver: Resolver) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController {
        return ViewControllerFactoryImpl(resolver: resolver).createNavigationController(from: nibName, bundle: bundle)
    }
}
#endif
