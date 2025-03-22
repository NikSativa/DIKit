import DIKit
import Threading
import XCTest

final class ThreadSafeResolutionTests: XCTestCase {
    private var container: Container!

    override func setUp() async throws {
        container = Container()
    }

    override func tearDown() async throws {
        container = nil
    }

    func test_thread_safe_resolution() async throws {
        // Register different types with different scopes
        container.register(Instance.self, options: .container) {
            return Instance(id: 1)
        }

        container.register(ObservableInstance.self, options: .weak) {
            return ObservableInstance(id: 2)
        }

        container.register(Value.self, options: .transient) {
            return Value(id: 3)
        }

        // Create multiple threads to resolve dependencies
        let iterations = 100
        let expectation = XCTestExpectation(description: "All resolutions completed")
        expectation.expectedFulfillmentCount = iterations * 3 // 3 types * 100 iterations
        let container: Container = container
        for _ in 0..<iterations {
            // Resolve Instance
            Task {
                XCTAssertFalse(Thread.isMainThread)
                let instance = container.resolve(Instance.self)
                XCTAssertEqual(instance.id, 1)
                expectation.fulfill()
            }

            // Resolve ObservableInstance
            Task {
                XCTAssertFalse(Thread.isMainThread)
                let instance = container.resolve(ObservableInstance.self)
                XCTAssertEqual(instance.id, 2)
                expectation.fulfill()
            }

            // Resolve Value
            Task {
                XCTAssertFalse(Thread.isMainThread)
                let value = container.resolve(Value.self)
                XCTAssertEqual(value.id, 3)
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func test_thread_safe_transient_resolution() async throws {
        // Register with transient scope
        container.register(Instance.self, options: .transient) {
            return Instance(id: Int.random(in: 1...1000))
        }

        // Create multiple threads to resolve dependencies
        let iterations = 100
        let expectation = XCTestExpectation(description: "All transient resolutions completed")
        expectation.expectedFulfillmentCount = iterations

        let container: Container = container
        for _ in 0..<iterations {
            Task { [container] in
                XCTAssertFalse(Thread.isMainThread)
                let instance = container.resolve(Instance.self)
                XCTAssertTrue(0...1000 ~= instance.id)
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func test_thread_safe_weak_resolution() async throws {
        // Register with weak scope
        container.register(Instance.self, options: .weak) {
            return Instance(id: 1)
        }

        // Create multiple threads to resolve dependencies
        let iterations = 100
        let expectation = XCTestExpectation(description: "All weak resolutions completed")
        expectation.expectedFulfillmentCount = iterations

        let container: Container = container
        for _ in 0..<iterations {
            Task {
                XCTAssertFalse(Thread.isMainThread)
                let instance = container.resolve(Instance.self)
                XCTAssertEqual(instance.id, 1)
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
