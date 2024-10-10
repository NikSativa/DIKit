import DIKit
import Foundation
import XCTest

@MainActor
final class ValueProviderTests: XCTestCase {
    private var resolvingCounter: Int = 0
    private let container: Container = .init(assemblies: [])

    private func setup(_ options: Options) {
        container.register(Value.self, options: options) {
            defer {
                self.resolvingCounter += 1
            }
            return Value(id: self.resolvingCounter)
        }
    }

    func test_when_registered_weak() {
        setup(.weak)

        var subject: Provider<Value> = container.resolveWrapped()
        XCTAssertEqual(resolvingCounter, 0)

        var i1: Value? = subject.instance
        XCTAssertEqual(resolvingCounter, 1)
        XCTAssertNotNil(i1)

        var i2: Value? = subject.instance
        XCTAssertEqual(resolvingCounter, 2)
        XCTAssertNotNil(i2)
        XCTAssertNotEqual(i1, i2)

        // release prev instance
        i1 = nil
        i2 = nil

        subject = container.resolveWrapped()

        i1 = subject.instance
        XCTAssertEqual(resolvingCounter, 3)
        XCTAssertNotNil(i1)

        i2 = subject.instance
        XCTAssertEqual(resolvingCounter, 4)
        XCTAssertNotNil(i2)
        XCTAssertNotEqual(i1, i2)
    }

    func test_when_registered_transient() {
        setup(.transient)

        var subject: Provider<Value> = container.resolveWrapped()
        XCTAssertEqual(resolvingCounter, 0)

        var i1: Value? = subject.instance
        XCTAssertEqual(resolvingCounter, 1)
        XCTAssertNotNil(i1)

        var i2: Value? = subject.instance
        XCTAssertEqual(resolvingCounter, 2)
        XCTAssertNotNil(i2)
        XCTAssertNotEqual(i1, i2)

        // release prev instance
        i1 = nil
        i2 = nil

        subject = container.resolveWrapped()

        i1 = subject.instance
        XCTAssertEqual(resolvingCounter, 3)
        XCTAssertNotNil(i1)

        i2 = subject.instance
        XCTAssertEqual(resolvingCounter, 4)
        XCTAssertNotNil(i2)
        XCTAssertNotEqual(i1, i2)
    }

    func test_when_registered_container() {
        setup(.container)

        var subject: Provider<Value> = container.resolveWrapped()
        XCTAssertEqual(resolvingCounter, 0)

        var i1: Value? = subject.instance
        XCTAssertEqual(resolvingCounter, 1)
        XCTAssertNotNil(i1)

        var i2: Value? = subject.instance
        XCTAssertEqual(resolvingCounter, 1)
        XCTAssertNotNil(i2)
        XCTAssertEqual(i1, i2)

        // release prev instance
        i1 = nil
        i2 = nil

        subject = container.resolveWrapped()

        i1 = subject.instance
        XCTAssertEqual(resolvingCounter, 1) // retained by container
        XCTAssertNotNil(i1)

        i2 = subject.instance
        XCTAssertEqual(resolvingCounter, 1)
        XCTAssertNotNil(i2)
        XCTAssertEqual(i1, i2)
    }
}
