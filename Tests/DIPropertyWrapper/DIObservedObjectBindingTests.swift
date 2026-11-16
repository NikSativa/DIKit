#if canImport(SwiftUI)
import DIKit
import Foundation
import SwiftUI
import XCTest

@MainActor
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class DIObservedObjectBindingTests: XCTestCase {
    func test_writing_another_instance_through_the_projected_binding_replaces_the_instance() {
        let container = Container(assemblies: [])
        container.register(ObservableInstance.self, options: .transient) {
            return ObservableInstance(id: 1)
        }
        let view = ReplaceableInstanceView()
        let capture = ImageRenderer(content: view.environmentObject(container.toObservable())).actualImage
        XCTAssertNotNil(capture)
        XCTAssertEqual(view.instance.id, 1)

        view.$instance.wrappedValue = ObservableInstance(id: 2)

        XCTAssertEqual(view.instance.id, 2)
        XCTAssertEqual(view.$instance.wrappedValue.id, 2)
    }
}

private struct ReplaceableInstanceView: View {
    @DIObservedObject
    var instance: ObservableInstance

    @ViewBuilder
    var body: some View {
        Text("Instance: \(instance.id)")
    }
}
#endif
