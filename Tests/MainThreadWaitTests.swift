import Foundation
import Threading
import XCTest
@testable import DIKit

private final class MainProbe {}

private final class Service {
    let probe: MainProbe

    init(probe: MainProbe) {
        self.probe = probe
    }
}

private final class Session {
    let token: String
    let probe: MainProbe

    init(token: String, probe: MainProbe) {
        self.token = token
        self.probe = probe
    }
}

private final class Feature {
    let service: Service

    init(service: Service) {
        self.service = service
    }
}

private final class CallCounter: @unchecked Sendable {
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

private final class ResultBox<Value>: @unchecked Sendable {
    @AtomicValue(lock: .pthread(.recursive))
    var value: Value? = nil
}

private final class BackgroundFactoryProbe: @unchecked Sendable {
    let calls = CallCounter()
    private let started = DispatchSemaphore(value: 0)

    func recordCall() {
        calls.increment()
        if !Thread.isMainThread {
            started.signal()
        }
    }

    func waitUntilTheBackgroundThreadRunsTheFactory() {
        started.wait()
    }
}

final class MainThreadWaitTests: XCTestCase {
    func test_the_main_thread_gets_a_container_entity_while_its_background_creator_waits_for_the_main_thread() {
        assertTheMainThreadGetsTheEntityWhileItsBackgroundCreatorWaitsForTheMainThread(options: .container)
    }

    func test_the_main_thread_gets_a_weak_entity_while_its_background_creator_waits_for_the_main_thread() {
        assertTheMainThreadGetsTheEntityWhileItsBackgroundCreatorWaitsForTheMainThread(options: .weak)
    }

    func test_the_main_thread_gets_a_chain_of_entities_while_their_background_creator_waits_for_the_main_thread() {
        let container = makeContainerWithMainProbe()
        let featureFactory = BackgroundFactoryProbe()
        let serviceFactory = BackgroundFactoryProbe()
        container.register(Feature.self, options: .container) { resolver in
            featureFactory.recordCall()
            return Feature(service: resolver.resolve())
        }
        container.register(Service.self, options: .container) { resolver in
            serviceFactory.recordCall()
            return Service(probe: resolver.resolve())
        }

        let backgroundFeature = ResultBox<Feature>()
        let backgroundResolved = expectation(description: "The background thread resolves the feature")
        startUserInteractiveThread {
            backgroundFeature.value = container.resolve()
            backgroundResolved.fulfill()
        }
        serviceFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainFeature: Feature = container.resolve()
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertTrue(backgroundFeature.value === mainFeature)
        XCTAssertTrue(backgroundFeature.value?.service === mainFeature.service)
        XCTAssertEqual(featureFactory.calls.value, 2)
        XCTAssertEqual(serviceFactory.calls.value, 2)
    }

    func test_the_main_thread_runs_the_second_factory_call_with_the_arguments_of_the_first_call() {
        let container = makeContainerWithMainProbe()
        let sessionFactory = BackgroundFactoryProbe()
        container.register(Session.self, options: .container) { resolver, arguments in
            sessionFactory.recordCall()
            return Session(token: arguments.first(), probe: resolver.resolve())
        }

        let backgroundSession = ResultBox<Session>()
        let backgroundResolved = expectation(description: "The background thread resolves the session")
        startUserInteractiveThread {
            backgroundSession.value = container.resolve(with: Arguments("first token"))
            backgroundResolved.fulfill()
        }
        sessionFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainSession: Session = container.resolve()
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertTrue(backgroundSession.value === mainSession)
        XCTAssertEqual(mainSession.token, "first token")
        XCTAssertEqual(sessionFactory.calls.value, 2)
    }

    func test_a_background_creator_does_not_wait_for_the_main_thread_when_the_main_thread_entity_exists() {
        let container = Container(assemblies: [])
        container.isolatedMain.register(MainProbe.self, options: .container) {
            return MainProbe()
        }
        let serviceFactory = BackgroundFactoryProbe()
        container.register(Service.self, options: .container) { resolver in
            serviceFactory.recordCall()
            return Service(probe: resolver.resolve())
        }
        let mainProbe: MainProbe = container.resolve()

        let backgroundService = ResultBox<Service>()
        let backgroundResolved = expectation(description: "The background thread resolves the service")
        startUserInteractiveThread {
            backgroundService.value = container.resolve()
            backgroundResolved.fulfill()
        }
        serviceFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainService: Service = container.resolve()
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertTrue(backgroundService.value === mainService)
        XCTAssertTrue(mainService.probe === mainProbe)
        XCTAssertEqual(serviceFactory.calls.value, 1)
    }

    func test_the_main_thread_gets_a_lazy_value_while_its_background_reader_waits_for_the_main_thread() {
        let container = makeContainerWithMainProbe()
        let lazyFactory = BackgroundFactoryProbe()
        let lazy = Lazy<Service> {
            lazyFactory.recordCall()
            return Service(probe: container.resolve())
        }

        let backgroundService = ResultBox<Service>()
        let backgroundResolved = expectation(description: "The background thread reads the lazy value")
        startUserInteractiveThread {
            backgroundService.value = lazy.wrappedValue
            backgroundResolved.fulfill()
        }
        lazyFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainService = lazy.wrappedValue
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertTrue(backgroundService.value === mainService)
        XCTAssertTrue(lazy.wrappedValue === mainService)
        XCTAssertEqual(lazyFactory.calls.value, 2)
    }

    func test_the_main_thread_gets_a_weak_lazy_value_while_its_background_reader_waits_for_the_main_thread() {
        let container = makeContainerWithMainProbe()
        let weakLazyFactory = BackgroundFactoryProbe()
        let weakLazy = WeakLazy<Service?> {
            weakLazyFactory.recordCall()
            return Service(probe: container.resolve())
        }

        let backgroundService = ResultBox<Service?>()
        let backgroundResolved = expectation(description: "The background thread reads the weak lazy value")
        startUserInteractiveThread {
            backgroundService.value = weakLazy.wrappedValue
            backgroundResolved.fulfill()
        }
        weakLazyFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainService = weakLazy.wrappedValue
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertNotNil(mainService)
        XCTAssertTrue(backgroundService.value.flatMap { $0 } === mainService)
        XCTAssertTrue(weakLazy.wrappedValue === mainService)
        XCTAssertEqual(weakLazyFactory.calls.value, 2)
    }

    func test_the_main_thread_gets_a_provider_value_while_its_background_reader_waits_for_the_main_thread() {
        let container = makeContainerWithMainProbe()
        let providerFactory = BackgroundFactoryProbe()
        let provider = Provider<Service> {
            providerFactory.recordCall()
            return Service(probe: container.resolve())
        }

        let backgroundService = ResultBox<Service>()
        let backgroundResolved = expectation(description: "The background thread reads the provider value")
        startUserInteractiveThread {
            backgroundService.value = provider.wrappedValue
            backgroundResolved.fulfill()
        }
        providerFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainService = provider.wrappedValue
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertNotNil(backgroundService.value)
        XCTAssertFalse(backgroundService.value === mainService)
        XCTAssertEqual(providerFactory.calls.value, 2)
    }

    private func assertTheMainThreadGetsTheEntityWhileItsBackgroundCreatorWaitsForTheMainThread(options: Options,
                                                                                               file: StaticString = #filePath,
                                                                                               line: UInt = #line) {
        let container = makeContainerWithMainProbe()
        let serviceFactory = BackgroundFactoryProbe()
        container.register(Service.self, options: options) { resolver in
            serviceFactory.recordCall()
            return Service(probe: resolver.resolve())
        }

        let backgroundService = ResultBox<Service>()
        let backgroundResolved = expectation(description: "The background thread resolves the service")
        startUserInteractiveThread {
            backgroundService.value = container.resolve()
            backgroundResolved.fulfill()
        }
        serviceFactory.waitUntilTheBackgroundThreadRunsTheFactory()

        let mainService: Service = container.resolve()
        wait(for: [backgroundResolved], timeout: 10)

        XCTAssertTrue(backgroundService.value === mainService, file: file, line: line)
        XCTAssertEqual(serviceFactory.calls.value, 2, file: file, line: line)
    }

    private func makeContainerWithMainProbe() -> Container {
        let container = Container(assemblies: [])
        container.isolatedMain.register(MainProbe.self, options: .transient) {
            return MainProbe()
        }
        return container
    }

    private func startUserInteractiveThread(_ work: @escaping @Sendable () -> Void) {
        let thread = Thread(block: work)
        thread.qualityOfService = .userInteractive
        thread.start()
    }
}
