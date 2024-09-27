#if canImport(SwiftUI)
import DIKit
import Foundation
import SwiftUI
import XCTest

protocol DIPropertyWrapperView: View {
    init(args: Instance?)
}

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
class DIPropertyWrapperTestCase<AppView: DIPropertyWrapperView>: XCTestCase {
    private var resolvingCounter: Int = 0
    private var resolvedArgs: [Bool] = []
    private let container: Container = .init(assemblies: [])

    @MainActor
    func run_test(options: Options,
                  resolvingCounterByStep expectedResolvingCounter: [Int],
                  argsShouldBeDeallocatedAfterFirstResolve argsShouldBeDeallocated: Bool,
                  file: StaticString = #filePath,
                  line: UInt = #line) {
        setup(options)

        var instanceHolder: Instance? = .init(id: 11)
        weak var instanceWeak = instanceHolder
        XCTAssertNotNil(instanceWeak, "initializing args", file: file, line: line)

        var appView: (some View)? = makeAppView(instanceHolder)
        instanceHolder = nil
        XCTAssertEqual(resolvingCounter, 0, "initializing view", file: file, line: line)
        XCTAssertNotNil(instanceWeak, "args should be alive", file: file, line: line)
        XCTAssertTrue(resolvedArgs.isEmpty, "not yet resolved", file: file, line: line)

        let capture = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture, "the first draw", file: file, line: line)
        XCTAssertEqual(resolvingCounter, expectedResolvingCounter[0], "the first resolve", file: file, line: line)
        if argsShouldBeDeallocated {
            XCTAssertNil(instanceWeak, "args should be deallocated", file: file, line: line)
        } else {
            XCTAssertNotNil(instanceWeak, "args should be alive", file: file, line: line)
        }
        XCTAssertEqual(resolvedArgs, [true], "resolving with args (step 1)", file: file, line: line)

        let capture2 = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture2, "the second draw", file: file, line: line)
        XCTAssertEqual(resolvingCounter, expectedResolvingCounter[1], "the second resolve", file: file, line: line)
        XCTAssertTrue(zip(resolvedArgs, [true, !argsShouldBeDeallocated]).allSatisfy(==), "resolving \(argsShouldBeDeallocated ? "without" : "with") args (step 2)", file: file, line: line)

        appView = nil
        let appView2 = makeAppView(instanceHolder) // make new with 'nil'

        let capture3 = ImageRenderer(content: appView2).actualImage
        XCTAssertNotNil(capture3, file: file, line: line)
        XCTAssertEqual(resolvingCounter, expectedResolvingCounter[2], "new view", file: file, line: line)
        XCTAssertTrue(zip(resolvedArgs, resolvedArgs.count == 2 ? [true, false] : [true, !argsShouldBeDeallocated, false]).allSatisfy(==), "new view without args", file: file, line: line)
    }

    @MainActor
    private func makeAppView(_ instance: Instance?) -> some View {
        return AppView(args: instance)
            .environmentObject(container.toObservable())
    }

    @MainActor
    private func setup(_ option: Options) {
        container.register(ObservableInstance.self, options: option) { _, args in
            defer {
                self.resolvingCounter += 1
            }
            self.resolvedArgs.append(!args.isEmpty)
            return .init(id: self.resolvingCounter)
        }

        container.register(Instance.self, options: option) { _, args in
            defer {
                self.resolvingCounter += 1
            }
            self.resolvedArgs.append(!args.isEmpty)
            return .init(id: self.resolvingCounter)
        }

        container.register(Value.self, options: option) { _, args in
            defer {
                self.resolvingCounter += 1
            }
            self.resolvedArgs.append(!args.isEmpty)
            return .init(id: self.resolvingCounter)
        }
    }
}
#endif
