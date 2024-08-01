#if os(iOS) && canImport(UIKit)
import Foundation
import UIKit

@testable import DIKit

public enum ViewControllerFactoryTestHelper {
    public static func instantiate<T>(from nibName: String? = nil, bundle: Bundle? = nil, resolver: Resolver) -> T where T: UIViewController {
        return Impl.ViewControllerFactory(resolver: resolver).instantiate(from: nibName, bundle: bundle)
    }

    public static func createNavigationController<T, N>(from nibName: String? = nil, bundle: Bundle? = nil, resolver: Resolver) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController {
        return Impl.ViewControllerFactory(resolver: resolver).createNavigationController(from: nibName, bundle: bundle)
    }
}
#endif
