import Foundation
import Threading
import XCTest
@testable import DIKit

private final class MainActorProbe {}

private struct MainActorProbeResolution {
    let objects: [AnyObject]
    let factoryCalls: Int

    var distinctObjectCount: Int {
        return Set(objects.map(ObjectIdentifier.init)).count
    }
}

private final class FactoryCallCounter: @unchecked Sendable {
    @AtomicValue(lock: .pthread(.recursive))
    private var storedValue = 0

    var value: Int {
        return storedValue
    }

    func increment() {
        $storedValue {
            $0 += 1
        }
    }
}

private final class ObjectList: @unchecked Sendable {
    @AtomicValue(lock: .pthread(.recursive))
    private var storedObjects: [AnyObject] = []

    var objects: [AnyObject] {
        return storedObjects
    }

    func append(_ object: AnyObject) {
        $storedObjects {
            $0.append(object)
        }
    }
}

final class IsolatedMainResolutionTests: XCTestCase {
    func test_background_threads_and_the_main_thread_share_one_main_actor_container_entity_without_blocking_each_other() {
        let resolution = resolveMainActorProbeFromBackgroundThreadsAndMainThread(options: .container, backgroundThreadCount: 4)

        XCTAssertEqual(resolution.objects.count, 5)
        XCTAssertEqual(resolution.distinctObjectCount, 1)
        XCTAssertEqual(resolution.factoryCalls, 1)
    }

    func test_background_threads_and_the_main_thread_share_one_main_actor_weak_entity_without_blocking_each_other() {
        let resolution = resolveMainActorProbeFromBackgroundThreadsAndMainThread(options: .weak, backgroundThreadCount: 4)

        XCTAssertEqual(resolution.objects.count, 5)
        XCTAssertEqual(resolution.distinctObjectCount, 1)
        XCTAssertEqual(resolution.factoryCalls, 1)
    }

    func test_background_threads_and_the_main_thread_get_separate_main_actor_transient_entities_without_blocking_each_other() {
        let resolution = resolveMainActorProbeFromBackgroundThreadsAndMainThread(options: .transient, backgroundThreadCount: 4)

        XCTAssertEqual(resolution.objects.count, 5)
        XCTAssertEqual(resolution.distinctObjectCount, 5)
        XCTAssertEqual(resolution.factoryCalls, 5)
    }

    private func resolveMainActorProbeFromBackgroundThreadsAndMainThread(options: Options,
                                                                         backgroundThreadCount: Int) -> MainActorProbeResolution {
        XCTAssertTrue(Thread.isMainThread)
        let container = Container(assemblies: [])
        let factoryCalls = FactoryCallCounter()
        container.isolatedMain.register(MainActorProbe.self, options: options) {
            factoryCalls.increment()
            return MainActorProbe()
        }
        let backgroundResults = ObjectList()
        let backgroundThreadsFinished = expectation(description: "The background threads resolve the main-actor entity")
        backgroundThreadsFinished.expectedFulfillmentCount = backgroundThreadCount

        for _ in 0..<backgroundThreadCount {
            Thread.detachNewThread {
                let probe: MainActorProbe = container.resolve()
                backgroundResults.append(probe)
                backgroundThreadsFinished.fulfill()
            }
        }

        let probe: MainActorProbe = container.resolve()
        wait(for: [backgroundThreadsFinished], timeout: 10)

        return MainActorProbeResolution(objects: [probe] + backgroundResults.objects,
                                        factoryCalls: factoryCalls.value)
    }
}
