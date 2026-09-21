import DIKit
import DIKitTesting
import Testing

private final class InstanceConsumer {
    @Inject
    var instance: Instance
}

private actor ScopeGauge {
    private var active = 0
    private(set) var peak = 0

    func enter() {
        active += 1
        peak = max(peak, active)
    }

    func leave() {
        active -= 1
    }
}

private func makeContainer(id: Int) -> Container {
    let container = Container(assemblies: [])
    container.register(Instance.self, options: .transient) { _, _ in
        return Instance(id: id)
    }
    return container
}

struct InjectSettingsTests {
    @Test(arguments: 0..<40)
    func eachTestCaseResolvesFromItsOwnScope(id: Int) async throws {
        try await InjectSettings.withResolver(makeContainer(id: id)) {
            try await Task.sleep(nanoseconds: 10_000_000)
            #expect(InstanceConsumer().instance.id == id)
        }
    }

    @Test
    func concurrentScopesDoNotLeakIntoEachOther() async throws {
        let gauge = ScopeGauge()
        try await withThrowingTaskGroup(of: (Int, Int).self) { group in
            for id in 0..<50 {
                group.addTask {
                    return try await InjectSettings.withResolver(makeContainer(id: id)) {
                        await gauge.enter()
                        try await Task.sleep(nanoseconds: 20_000_000)
                        let resolved = InstanceConsumer().instance.id
                        await gauge.leave()
                        return (id, resolved)
                    }
                }
            }
            for try await (id, resolved) in group {
                #expect(resolved == id)
            }
        }
        #expect(await gauge.peak > 1)
    }

    @Test
    func synchronousScopeResolvesFromItsResolver() {
        let id = InjectSettings.withResolver(makeContainer(id: 7)) {
            return InstanceConsumer().instance.id
        }
        #expect(id == 7)
    }

    #if compiler(>=6.2) && os(macOS)
    @Test
    func sharedContainerIsUsedOutsideTheScope() async {
        await #expect(processExitsWith: .success) {
            let shared = makeContainer(id: 1)
            shared.makeShared()
            let inside = InjectSettings.withResolver(makeContainer(id: 2)) {
                return InstanceConsumer().instance.id
            }
            let outside = InstanceConsumer().instance.id
            guard inside == 2, outside == 1 else {
                fatalError("inside: \(inside), outside: \(outside)")
            }
        }
    }

    @Test
    func razingTheSharedContainerDoesNotTrap() async {
        await #expect(processExitsWith: .success) {
            let container = Container(assemblies: [])
            container.makeShared()
            container.razeShared()
        }
    }
    #endif
}
