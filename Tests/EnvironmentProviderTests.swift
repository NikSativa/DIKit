import DIKit
import Foundation
import SpryKit
import SwiftUI
import XCTest

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class EnvironmentProviderTests: XCTestCase {
    private var resolvingCounter: Int = 0
    private let container: Container = .init(assemblies: [])
    private func makeAppView() -> some View {
        return AppView(container: container)
            .environmentObject(container.toObservable())
    }

    private func setup(_ option: Options) {
        container.register(Instance.self, options: option) {
            defer {
                self.resolvingCounter += 1
            }
            return Instance(id: self.resolvingCounter)
        }
    }

    @MainActor
    func test_when_registered_weak() {
        setup(.weak)

        var appView: (some View)? = makeAppView()
        XCTAssertEqual(resolvingCounter, 0)

        let capture = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture)
        XCTAssertEqual(resolvingCounter, 1)

        let capture2 = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture2)
        XCTAssertEqual(resolvingCounter, 2)

        appView = nil
        let appView2 = makeAppView()

        let capture3 = ImageRenderer(content: appView2).actualImage
        XCTAssertNotNil(capture3)
        XCTAssertEqual(resolvingCounter, 3)
    }

    @MainActor
    func test_when_registered_transient() {
        setup(.transient)

        var appView: (some View)? = makeAppView()
        XCTAssertEqual(resolvingCounter, 0)

        let capture = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture)
        XCTAssertEqual(resolvingCounter, 1)

        let capture2 = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture2)
        XCTAssertEqual(resolvingCounter, 2)

        appView = nil
        let appView2 = makeAppView()

        let capture3 = ImageRenderer(content: appView2).actualImage
        XCTAssertNotNil(capture3)
        XCTAssertEqual(resolvingCounter, 3)
    }

    @MainActor
    func test_when_registered_container() {
        setup(.container)

        var appView: (some View)? = makeAppView()
        XCTAssertEqual(resolvingCounter, 0)

        let capture = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture)
        XCTAssertEqual(resolvingCounter, 1)

        let capture2 = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture2)
        XCTAssertEqual(resolvingCounter, 1)

        appView = nil
        let appView2 = makeAppView()

        let capture3 = ImageRenderer(content: appView2).actualImage
        XCTAssertNotNil(capture3)
        XCTAssertEqual(resolvingCounter, 1)
    }
}

private struct AppView: View {
    private let container: Container
    @EnvironmentProvider var instance: Instance

    init(container: Container) {
        self.container = container
    }

    var body: some View {
        Text("Instance: \(instance.id)")
    }
}
