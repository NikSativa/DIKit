import DIKit
import Foundation
import SpryKit
import XCTest

final class ValueLazyTests: XCTestCase {
    private var resolvingCounter: Int = 0
    private let container: Container = .init(assemblies: [])

    private func setup(_ option: Options) {
        container.register(Value.self, options: option) {
            defer {
                self.resolvingCounter += 1
            }
            return Value(id: self.resolvingCounter)
        }
    }

    func test_when_registered_weak() {
        setup(.weak)

        var subject: Lazy<Value> = container.resolveWrapped()
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
        XCTAssertEqual(resolvingCounter, 2) // retained by wrapper
        XCTAssertNotNil(i1)

        i2 = subject.instance
        XCTAssertEqual(resolvingCounter, 2)
        XCTAssertNotNil(i2)
        XCTAssertEqual(i1, i2)
    }

    func test_when_registered_transient() {
        setup(.transient)

        var subject: Lazy<Value> = container.resolveWrapped()
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
        XCTAssertEqual(resolvingCounter, 2) // retained by wrapper
        XCTAssertNotNil(i1)

        i2 = subject.instance
        XCTAssertEqual(resolvingCounter, 2)
        XCTAssertNotNil(i2)
        XCTAssertEqual(i1, i2)
    }

    func test_when_registered_container() {
        setup(.container)

        var subject: Lazy<Value> = container.resolveWrapped()
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
