#if canImport(SwiftUI)
import Combine
import DIKit
import Foundation
import SwiftUI
import XCTest

@MainActor
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class DIStateBindingTests: XCTestCase {
    func test_writing_another_value_through_the_projected_binding_redraws_the_view() throws {
        let container = Container(assemblies: [])
        container.register(Value.self, options: .transient) {
            return Value(id: 1)
        }
        let recorder = DrawRecorder()
        let renderer = ImageRenderer(content: ReplaceableValueView(recorder: recorder).environmentObject(container.toObservable()))

        XCTAssertNotNil(renderer.actualImage)
        XCTAssertEqual(recorder.drawnIDs, [1])

        let rendererInvalidated = expectation(description: "The renderer learns that the view changed")
        let subscription = renderer.objectWillChange.sink { _ in
            rendererInvalidated.fulfill()
        }
        let binding = try XCTUnwrap(recorder.binding)
        binding.wrappedValue = Value(id: 2)
        wait(for: [rendererInvalidated], timeout: 10)
        subscription.cancel()

        XCTAssertNotNil(renderer.actualImage)
        XCTAssertEqual(recorder.drawnIDs, [1, 2])
    }
}

@MainActor
private final class DrawRecorder {
    var drawnIDs: [Int] = []
    var binding: Binding<Value>?
}

private struct ReplaceableValueView: View {
    @DIState
    var value: Value
    let recorder: DrawRecorder

    var body: some View {
        recorder.drawnIDs.append(value.id)
        recorder.binding = $value
        return Text("Value: \(value.id)")
    }
}
#endif
