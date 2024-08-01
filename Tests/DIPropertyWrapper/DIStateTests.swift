#if canImport(SwiftUI)
import DIKit
import Foundation
import SwiftUI

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class DIStateTests: DIPropertyWrapperTestCase<DIStateView> {
    @MainActor
    func test_when_registered_transient() throws {
        run_test(options: .transient, counter: [0, 1, 1, 2], resolvedArgs: [true, false])
    }

    @MainActor
    func test_when_registered_weak() throws {
        run_test(options: .weak, counter: [0, 1, 1, 2], resolvedArgs: [true, false])
    }

    @MainActor
    func test_when_registered_container() throws {
        run_test(options: .container, counter: [0, 1, 1, 1], resolvedArgs: [true])
    }
}

struct DIStateView: DIPropertyWrapperView {
    @DIState var instance: Value

    init(args: Instance?) {
        self._instance = .init(with: args.map { [$0] })
    }

    var body: some View {
        Text("Instance: \(instance.id)")
    }
}
#endif
