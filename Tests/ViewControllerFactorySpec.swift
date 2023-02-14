#if os(iOS)
import Foundation
import Nimble
import NSpry
import Quick
import UIKit
@testable import NInject
@testable import NInjectTestHelpers

final class NViewControllerFactorySpec: QuickSpec {
    override func spec() {
        describe("NViewControllerFactory") {
            var subject: ViewControllerFactory!

            beforeEach {
                let container = Container()
                container.registerStoryboardable(TestViewController.self) { _, _ in }
                subject = Impl.ViewControllerFactory(container: container)
            }

            describe("creating view controller") {
                var viewController: TestViewController?

                beforeEach {
                    viewController = subject.instantiate(bundle: .module)
                }

                it("should create corresponded view controller") {
                    expect(viewController).toNot(beNil())
                }
            }

            describe("creating navigation controller") {
                var actual: (navigation: UINavigationController, root: TestViewController)?

                beforeEach { @MainActor in
                    actual = subject.createNavigationController(bundle: .module)
                }

                it("should create corresponded navigation controller") { @MainActor in
                    expect(actual?.navigation).to(beAnInstanceOf(UINavigationController.self))
                    expect(actual?.navigation.viewControllers.first).to(beAnInstanceOf(TestViewController.self))
                    expect(actual?.root).to(beAnInstanceOf(TestViewController.self))
                }
            }
        }
    }
}
#endif
