#if os(iOS) && canImport(UIKit)
import Foundation
import UIKit

/// A factory that creates view controllers. It is used to instantiate view controllers from a storyboard or a nib file and resolve their dependencies.
@MainActor
public protocol ViewControllerFactory {
    /// Instantiates a view controller from a nib file.
    func instantiate<T>(from nibName: String?, bundle: Bundle?) -> T
        where T: UIViewController

    /// Creates a navigation controller with a root view controller from a nib file.
    func createNavigationController<T, N>(from nibName: String?, bundle: Bundle?) -> (navigation: N, root: T)
        where T: UIViewController, N: UINavigationController
}

public extension ViewControllerFactory {
    /// Instantiates a view controller from a nib file.
    func instantiate<T: UIViewController>(_: T.Type = T.self, from nibName: String? = nil, bundle: Bundle? = nil) -> T {
        return instantiate(from: nibName, bundle: bundle)
    }

    /// Creates a navigation controller with a root view controller from a nib file.
    func createNavigationController<T, N>(_: T.Type = T.self,
                                          navigation: N.Type = UINavigationController.self,
                                          from nibName: String? = nil,
                                          bundle: Bundle = .main) -> (navigation: N, root: T)
    where T: UIViewController, N: UINavigationController {
        return createNavigationController(from: nibName, bundle: bundle)
    }
}

final class ViewControllerFactoryImpl {
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

extension ViewControllerFactoryImpl: ViewControllerFactory {
    func instantiate<T: UIViewController>(from nibName: String? = nil, bundle: Bundle? = nil) -> T {
        let klass: String = nibName ?? String(describing: T.self)
        let storyboard = UIStoryboard(name: klass, bundle: bundle)

        let controller: T = instantiateInitialViewController(from: storyboard)
        controller.resolveDependnciesIfNeeded(with: resolver)
        return controller
    }

    func createNavigationController<T, N>(from nibName: String? = nil, bundle: Bundle? = nil) -> (navigation: N, root: T)
    where T: UIViewController, N: UINavigationController {
        let root: T = instantiate(from: nibName, bundle: bundle)
        return (N(rootViewController: root), root)
    }
}
#endif
