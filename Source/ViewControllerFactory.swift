#if os(iOS) && canImport(UIKit)
import Foundation
import UIKit

public protocol ViewControllerFactory {
    @MainActor
    func instantiate<T>(from nibName: String?, bundle: Bundle?) -> T
        where T: UIViewController

    @MainActor
    func createNavigationController<T, N>(from nibName: String?, bundle: Bundle?) -> (navigation: N, root: T)
        where T: UIViewController, N: UINavigationController
}

public extension ViewControllerFactory {
    @MainActor
    func instantiate<T: UIViewController>(_: T.Type = T.self, from nibName: String? = nil, bundle: Bundle? = nil) -> T {
        return instantiate(from: nibName, bundle: bundle)
    }

    @MainActor
    func createNavigationController<T, N>(_: T.Type = T.self,
                                          navigation: N.Type = UINavigationController.self,
                                          from nibName: String? = nil,
                                          bundle: Bundle = .main) -> (navigation: N, root: T)
    where T: UIViewController, N: UINavigationController {
        return createNavigationController(from: nibName, bundle: bundle)
    }
}

extension Impl {
    final class ViewControllerFactory {
        private let resolver: Resolver

        init(resolver: Resolver) {
            self.resolver = resolver
        }

        @MainActor
        private func instantiateInitialViewController<T: UIViewController>(from storyboard: UIStoryboard) -> T {
            if #available(iOS 13.0, *),
               let controller = storyboard.instantiateInitialViewController(creator: { T(coder: $0) }) {
                return controller
            }
            return storyboard.instantiateInitialViewController() as! T
        }
    }
}

extension Impl.ViewControllerFactory: ViewControllerFactory {
    @MainActor
    func instantiate<T: UIViewController>(from nibName: String? = nil, bundle: Bundle? = nil) -> T {
        let klass: String = nibName ?? String(describing: T.self)
        let storyboard = UIStoryboard(name: klass, bundle: bundle)

        let controller: T = instantiateInitialViewController(from: storyboard)
        #if canImport(ObjectiveC)
        controller.resolveDependnciesIfNeeded(with: resolver)
        #endif
        return controller
    }

    @MainActor
    func createNavigationController<T, N>(from nibName: String? = nil, bundle: Bundle? = nil) -> (navigation: N, root: T)
    where T: UIViewController, N: UINavigationController {
        let root: T = instantiate(from: nibName, bundle: bundle)
        return (N(rootViewController: root), root)
    }
}
#endif
