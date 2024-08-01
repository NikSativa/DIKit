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
                  counter: [Int],
                  resolvedArgs expectedResolvedArgs: [Bool],
                  argsShouldBeAlive: Bool = true,
                  file: StaticString = #file,
                  line: UInt = #line) {
        setup(options)

        var instanceHolder: Instance? = .init(id: 11)
        weak var instanceWeak = instanceHolder
        XCTAssertNotNil(instanceWeak, "initializing args", file: file, line: line)

        var appView: (some View)? = makeAppView(instanceHolder)
        instanceHolder = nil
        XCTAssertEqual(resolvingCounter, counter[0], "initializing view", file: file, line: line)
        XCTAssertNotNil(instanceWeak, "args should be alive", file: file, line: line)
        XCTAssertTrue(resolvedArgs.isEmpty, "not yet resolved", file: file, line: line)

        let capture = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture, "the first draw", file: file, line: line)
        XCTAssertEqual(resolvingCounter, counter[1], "the first resolve", file: file, line: line)
        if argsShouldBeAlive {
            XCTAssertNil(instanceWeak, "args should be deallocated", file: file, line: line)
        } else {
            XCTAssertNotNil(instanceWeak, "args should be alive", file: file, line: line)
        }
        XCTAssertTrue(zip(resolvedArgs, expectedResolvedArgs).allSatisfy(==), "resolving with args", file: file, line: line)

        let capture2 = ImageRenderer(content: appView).actualImage
        XCTAssertNotNil(capture2, "the second draw", file: file, line: line)
        XCTAssertEqual(resolvingCounter, counter[2], "the second resolve", file: file, line: line)
        XCTAssertTrue(zip(resolvedArgs, expectedResolvedArgs).allSatisfy(==), "resolving with args", file: file, line: line)

        appView = nil
        let appView2 = makeAppView(instanceHolder)

        let capture3 = ImageRenderer(content: appView2).actualImage
        XCTAssertNotNil(capture3, file: file, line: line)
        XCTAssertEqual(resolvingCounter, counter[3], "new view", file: file, line: line)

        XCTAssertEqual(resolvedArgs, expectedResolvedArgs, "new view without args", file: file, line: line)
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
