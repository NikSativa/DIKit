#if canImport(SwiftUI)
import DIKit
import Foundation
import SwiftUI

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class DIObservedObjectTests: DIPropertyWrapperTestCase<DIObservedObjectView> {
    @MainActor
    func test_when_registered_transient() throws {
        run_test(options: .transient,
                 resolvingCounterByStep: [1, 1, 2],
                 argsShouldBeDeallocatedAfterFirstResolve: false)
    }

    @MainActor
    func test_when_registered_weak() throws {
        run_test(options: .weak,
                 resolvingCounterByStep: [1, 1, 2],
                 argsShouldBeDeallocatedAfterFirstResolve: false)
    }

    @MainActor
    func test_when_registered_container() throws {
        run_test(options: .container,
                 resolvingCounterByStep: [1, 1, 1],
                 argsShouldBeDeallocatedAfterFirstResolve: false)
    }
}

struct DIObservedObjectView: DIPropertyWrapperView {
    @DIObservedObject var instance: ObservableInstance

    init(args: Instance?) {
        self._instance = .init(with: args.map { [$0] })
    }

    var body: some View {
        Text("Instance: \(instance.id)")
    }
}
#endif
