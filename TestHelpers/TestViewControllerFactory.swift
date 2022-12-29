#if os(iOS)
import Foundation
import NSpry
import UIKit
@testable import NInject

public enum NTestViewControllerFactory {
    public static func instantiate<T>(from nibName: String? = nil, bundle: Bundle, container: Container) -> T where T: UIViewController {
        return Impl.ViewControllerFactory(container: container).instantiate(from: nibName, bundle: bundle)
    }

    public static func createNavigationController<T, N>(from nibName: String? = nil, bundle: Bundle, container: Container) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController {
        return Impl.ViewControllerFactory(container: container).createNavigationController(from: nibName, bundle: bundle)
    }
}
#endif
