#if compiler(>=6.1)
import DIKit
import DIKitTesting
import Testing

private final class ResolutionCounter: @unchecked Sendable {
    private var count = 0

    func increment() -> Int {
        count += 1
        return count
    }
}

private final class CounterConsumer {
    @Inject
    var counter: ResolutionCounter
}

private func makeCountingContainer() -> Container {
    let container = Container(assemblies: [])
    container.register(ResolutionCounter.self, options: .container) { _, _ in
        return ResolutionCounter()
    }
    return container
}

@Suite(.resolver { makeCountingContainer() })
struct ResolverScopeTests {
    @Test(arguments: 0..<20)
    func eachTestCaseGetsAFreshResolver(index: Int) async throws {
        try await Task.sleep(nanoseconds: 5_000_000)
        #expect(CounterConsumer().counter.increment() == 1)
    }

    @Test
    func injectResolvesFromTheTraitResolver() {
        #expect(InjectSettings.resolver != nil)
        #expect(CounterConsumer().counter.increment() == 1)
    }
}
#endif
