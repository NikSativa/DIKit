import DIKit
import Foundation
import XCTest

final class LazyThreadSafetyTests: XCTestCase {
    func test_resolves_exactly_once_under_concurrent_access() {
        let counter = AtomicCounter()
        let lazy = Lazy<Instance> {
            let id = counter.increment()
            return Instance(id: id)
        }

        let iterations = 1_000
        let resolved = AtomicArray<Instance?>(repeating: nil, count: iterations)

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            resolved.set(lazy.wrappedValue, at: index)
        }

        XCTAssertEqual(counter.value, 1)
        let snapshot = resolved.snapshot()
        let first = snapshot.first.flatMap { $0 }
        XCTAssertNotNil(first)
        for instance in snapshot {
            XCTAssertTrue(instance === first)
        }
    }

    func test_returns_same_instance_on_sequential_access() {
        var callCount = 0
        let lazy = Lazy<Instance> {
            callCount += 1
            return Instance(id: 42)
        }

        let first = lazy.wrappedValue
        let second = lazy.wrappedValue
        let third = lazy.wrappedValue

        XCTAssertEqual(callCount, 1)
        XCTAssertTrue(first === second)
        XCTAssertTrue(second === third)
    }

    func test_no_crash_under_first_access_race_regression() {
        for _ in 0..<100 {
            let counter = AtomicCounter()
            let lazy = Lazy<Instance> {
                Thread.sleep(forTimeInterval: 0.0001)
                return Instance(id: counter.increment())
            }

            DispatchQueue.concurrentPerform(iterations: 64) { _ in
                _ = lazy.wrappedValue
            }

            XCTAssertEqual(counter.value, 1)
        }
    }

    func test_slow_factory_blocks_other_threads_until_resolution_completes() {
        let startedFactory = expectation(description: "factory started")
        let allowFactoryToFinish = expectation(description: "factory allowed to finish")
        let resolutionReleased = DispatchSemaphore(value: 0)

        let lazy = Lazy<Instance> {
            startedFactory.fulfill()
            resolutionReleased.wait()
            return Instance(id: 7)
        }

        DispatchQueue.global().async {
            _ = lazy.wrappedValue
            allowFactoryToFinish.fulfill()
        }

        wait(for: [startedFactory], timeout: 1.0)

        let secondaryValues = AtomicArray<Instance>()
        let secondaryQueue = DispatchQueue(label: "secondary")
        let secondaryDone = expectation(description: "secondary readers done")
        secondaryDone.expectedFulfillmentCount = 16

        for _ in 0..<16 {
            secondaryQueue.async {
                secondaryValues.append(lazy.wrappedValue)
                secondaryDone.fulfill()
            }
        }

        // Let the secondaries accumulate while the factory is still blocked —
        // they must all be parked, none crashed.
        Thread.sleep(forTimeInterval: 0.05)
        resolutionReleased.signal()

        wait(for: [allowFactoryToFinish, secondaryDone], timeout: 2.0)
        let collected = secondaryValues.snapshot()
        XCTAssertEqual(collected.count, 16)
        XCTAssertTrue(collected.allSatisfy { $0.id == 7 })
    }
}

private final class AtomicArray<Element>: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [Element]

    init(repeating element: Element, count: Int) {
        self.storage = .init(repeating: element, count: count)
    }

    init() {
        self.storage = []
    }

    func set(_ element: Element, at index: Int) {
        lock.lock()
        defer { lock.unlock() }
        storage[index] = element
    }

    func append(_ element: Element) {
        lock.lock()
        defer { lock.unlock() }
        storage.append(element)
    }

    func snapshot() -> [Element] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }
}

private final class AtomicCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Int = 0

    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    @discardableResult
    func increment() -> Int {
        lock.lock()
        defer { lock.unlock() }
        _value += 1
        return _value
    }
}
