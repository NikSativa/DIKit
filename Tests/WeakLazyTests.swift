import DIKit
import Foundation
import Testing

private protocol Session: AnyObject {}

private final class AppSession: Session {
    let tracker: Tracker

    init(tracker: Tracker) {
        self.tracker = tracker
    }
}

private final class Tracker {
    let session: WeakLazy<(any Session)?>

    init(session: WeakLazy<(any Session)?>) {
        self.session = session
    }
}

private final class InstanceSource {
    var instance: Instance?
    private(set) var resolveCount = 0

    func resolve() -> Instance? {
        resolveCount += 1
        return instance
    }
}

private final class ConcurrentAccessLog: @unchecked Sendable {
    private let lock = NSLock()
    private var resolves = 0
    private var unexpectedResults = 0

    var resolveCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return resolves
    }

    var unexpectedResultCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return unexpectedResults
    }

    func recordResolve() {
        lock.lock()
        defer { lock.unlock() }
        resolves += 1
    }

    func record(_ result: Instance?, expected: Instance) {
        guard result !== expected else {
            return
        }

        lock.lock()
        defer { lock.unlock() }
        unexpectedResults += 1
    }
}

struct WeakLazyTests {
    @Test
    func resolvesOnlyOnFirstAccess() {
        let source = InstanceSource()
        source.instance = Instance(id: 1)
        let subject = WeakLazy<Instance?>(with: source.resolve)
        #expect(source.resolveCount == 0)

        let first = subject.wrappedValue
        let second = subject.wrappedValue

        #expect(source.resolveCount == 1)
        #expect(first === source.instance)
        #expect(second === source.instance)
    }

    @Test
    func returnsNilAfterTheInstanceIsDeallocated() {
        let source = InstanceSource()
        source.instance = Instance(id: 1)
        let subject = WeakLazy<Instance?>(with: source.resolve)
        #expect(subject.wrappedValue?.id == 1)

        source.instance = nil

        #expect(subject.wrappedValue == nil)
    }

    @Test
    func doesNotResolveAgainAfterTheInstanceIsDeallocated() {
        let source = InstanceSource()
        source.instance = Instance(id: 1)
        let subject = WeakLazy<Instance?>(with: source.resolve)
        _ = subject.wrappedValue
        source.instance = nil
        _ = subject.wrappedValue

        source.instance = Instance(id: 2)

        #expect(subject.wrappedValue == nil)
        #expect(source.resolveCount == 1)
    }

    @Test
    func returnsNilWhenTheFactoryReturnsNil() {
        let source = InstanceSource()
        let subject = WeakLazy<Instance?>(with: source.resolve)
        #expect(subject.wrappedValue == nil)

        source.instance = Instance(id: 1)

        #expect(subject.wrappedValue == nil)
        #expect(source.resolveCount == 1)
    }

    @Test
    func breaksTheCyclicDependencyOfAProtocolType() {
        let container = Container(assemblies: [])
        container.register((any Session).self, options: .weak) { resolver in
            return AppSession(tracker: Tracker(session: resolver.resolveWrapped()))
        }

        var session: (any Session)? = container.resolve()
        #if compiler(>=6.3)
        weak let releasedSession = session
        #else
        weak var releasedSession = session
        #endif
        let tracker = (session as? AppSession)?.tracker
        #expect(tracker?.session.wrappedValue === session)

        session = nil

        #expect(releasedSession == nil)
        #expect(tracker?.session.wrappedValue == nil)
    }

    @Test
    func resolvesOnceUnderConcurrentFirstAccess() {
        let instance = Instance(id: 1)
        let log = ConcurrentAccessLog()
        let subject = WeakLazy<Instance?> {
            log.recordResolve()
            return instance
        }

        DispatchQueue.concurrentPerform(iterations: 1_000) { _ in
            log.record(subject.wrappedValue, expected: instance)
        }

        #expect(log.resolveCount == 1)
        #expect(log.unexpectedResultCount == 0)
    }
}
