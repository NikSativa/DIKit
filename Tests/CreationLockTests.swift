import Foundation
import Threading
import XCTest
@testable import DIKit

private final class CreatedValue: Sendable {}

private final class CreatedValueSlot: @unchecked Sendable {
    var instance: CreatedValue?

    func store(_ created: CreatedValue) -> CreatedValue {
        if let instance {
            return instance
        }
        instance = created
        return created
    }
}

private final class CallTracker: @unchecked Sendable {
    @AtomicValue(lock: .pthread(.recursive))
    private var state: (calls: Int, activeCalls: Int, largestActiveCalls: Int) = (0, 0, 0)

    var calls: Int {
        return state.calls
    }

    var largestActiveCalls: Int {
        return state.largestActiveCalls
    }

    func enter() {
        $state {
            $0.calls += 1
            $0.activeCalls += 1
            $0.largestActiveCalls = max($0.largestActiveCalls, $0.activeCalls)
        }
    }

    func leave() {
        $state {
            $0.activeCalls -= 1
        }
    }
}

private final class ResultBox<Value>: @unchecked Sendable {
    @AtomicValue(lock: .pthread(.recursive))
    var value: Value? = nil
}

final class CreationLockTests: XCTestCase {
    func test_a_background_thread_waits_for_the_creator_that_waits_for_the_main_thread_instead_of_creating_a_second_value() {
        let creationLock = CreationLock()
        let slot = CreatedValueSlot()
        let creations = CallTracker()
        let secondReaderEntered = DispatchSemaphore(value: 0)
        let firstValue = ResultBox<CreatedValue>()
        let secondValue = ResultBox<CreatedValue>()
        let readersFinished = expectation(description: "Both background threads get the value")
        readersFinished.expectedFulfillmentCount = 2

        startUserInteractiveThread {
            firstValue.value = creationLock.resolve(cached: {
                return slot.instance
            }, create: {
                creations.enter()
                defer {
                    creations.leave()
                }
                return HeldLocks.current.released {
                    return Queue.isolatedMain.sync {
                        startUserInteractiveThread {
                            secondValue.value = creationLock.resolve(cached: {
                                secondReaderEntered.signal()
                                return slot.instance
                            }, create: {
                                creations.enter()
                                defer {
                                    creations.leave()
                                }
                                return CreatedValue()
                            }, store: slot.store)
                            readersFinished.fulfill()
                        }
                        secondReaderEntered.wait()
                        return CreatedValue()
                    }
                }
            }, store: slot.store)
            readersFinished.fulfill()
        }
        wait(for: [readersFinished], timeout: 10)

        XCTAssertNotNil(firstValue.value)
        XCTAssertTrue(firstValue.value === secondValue.value)
        XCTAssertEqual(creations.calls, 1)
    }

    func test_background_calls_do_not_run_at_the_same_time_while_one_of_them_waits_for_the_main_thread() {
        let creationLock = CreationLock()
        let calls = CallTracker()
        let secondCallerEntered = DispatchSemaphore(value: 0)
        let callersFinished = expectation(description: "Both background calls finish")
        callersFinished.expectedFulfillmentCount = 2

        startUserInteractiveThread {
            _ = creationLock.run {
                calls.enter()
                defer {
                    calls.leave()
                }
                return HeldLocks.current.released {
                    return Queue.isolatedMain.sync {
                        startUserInteractiveThread {
                            _ = creationLock.resolve(cached: {
                                secondCallerEntered.signal()
                                return Optional<CreatedValue>.none
                            }, create: {
                                calls.enter()
                                defer {
                                    calls.leave()
                                }
                                return CreatedValue()
                            }, store: { created in
                                return created
                            })
                            callersFinished.fulfill()
                        }
                        secondCallerEntered.wait()
                        return CreatedValue()
                    }
                }
            }
            callersFinished.fulfill()
        }
        wait(for: [callersFinished], timeout: 10)

        XCTAssertEqual(calls.calls, 2)
        XCTAssertEqual(calls.largestActiveCalls, 1)
    }

    func test_a_cached_value_is_read_while_another_thread_runs_a_creation() {
        let creationLock = CreationLock()
        let creationStarted = DispatchSemaphore(value: 0)
        let finishCreation = DispatchSemaphore(value: 0)
        let creationFinished = expectation(description: "The background creation finishes")

        startUserInteractiveThread {
            _ = creationLock.run {
                creationStarted.signal()
                finishCreation.wait()
                return CreatedValue()
            }
            creationFinished.fulfill()
        }
        creationStarted.wait()

        let cachedValue = creationLock.cachedValue {
            return 42
        }
        finishCreation.signal()
        wait(for: [creationFinished], timeout: 10)

        XCTAssertEqual(cachedValue, 42)
    }
}

private func startUserInteractiveThread(_ work: @escaping @Sendable () -> Void) {
    let thread = Thread(block: work)
    thread.qualityOfService = .userInteractive
    thread.start()
}
