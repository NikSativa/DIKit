
#if os(iOS)
import Foundation
import UIKit

public protocol ViewControllerFactory {
    func instantiate<T: UIViewController>(from nibName: String?, bundle: Bundle) -> T
    func createNavigationController<T, N>(from nibName: String?, bundle: Bundle) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController
}

extension Impl {
    final class ViewControllerFactory {
        private let container: Container

        init(container: Container) {
            self.container = container
        }

        private func instantiateInitialViewController<T: UIViewController>(from storyboard: UIStoryboard) -> T {
            if #available(iOS 13.0, *), let controller = storyboard.instantiateInitialViewController(creator: { T(coder: $0) }) {
                return controller
            }
            return storyboard.instantiateInitialViewController() as! T
        }
    }
}

extension Impl.ViewControllerFactory: ViewControllerFactory {
    func instantiate<T: UIViewController>(from nibName: String? = nil, bundle: Bundle) -> T {
        let klass: String = nibName ?? String(describing: T.self)
        let storyboard = UIStoryboard(name: klass, bundle: bundle)

        let controller: T = instantiateInitialViewController(from: storyboard)
        controller.resolveDependencies()
        return controller
    }

    func createNavigationController<T, N>(from nibName: String?, bundle: Bundle) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController {
        let root: T = instantiate(from: nibName, bundle: bundle)
        return (N(rootViewController: root), root)
    }
}

public extension ViewControllerFactory {
    func instantiate<T: UIViewController>(_: T.Type, from nibName: String?, bundle: Bundle) -> T {
        return instantiate(from: nibName, bundle: bundle)
    }

    func instantiate<T: UIViewController>(_: T.Type, bundle: Bundle) -> T {
        return instantiate(from: nil, bundle: bundle)
    }

    func instantiate<T: UIViewController>(bundle: Bundle) -> T {
        return instantiate(from: nil, bundle: bundle)
    }

    func createNavigationController<T, N>(bundle: Bundle) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController {
        return createNavigationController(from: nil, bundle: bundle)
    }

    func createNavigationController<T, N>(_: T.Type, bundle: Bundle) -> (navigation: N, root: T) where T: UIViewController, N: UINavigationController {
        return createNavigationController(from: nil, bundle: bundle)
    }
}
#endif
