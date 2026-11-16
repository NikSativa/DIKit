@_spi(Testing) import DIKit
import Testing

private final class InstanceConsumer {
    @InjectWeakLazy
    var instance: Instance?
}

struct InjectWeakLazyTests {
    @Test
    func resolvesFromTheSharedResolverOnFirstAccessAndKeepsAWeakReference() {
        let container = Container(assemblies: [])
        var resolveCount = 0
        container.register(Instance.self, options: .weak) {
            resolveCount += 1
            return Instance(id: resolveCount)
        }

        InjectSettings.withResolver(container) {
            let consumer = InstanceConsumer()
            #expect(resolveCount == 0)

            var instance = consumer.instance
            #expect(resolveCount == 1)
            #expect(consumer.instance === instance)
            #expect(consumer.$instance.wrappedValue === instance)

            instance = nil

            #expect(consumer.instance == nil)
            #expect(resolveCount == 1)
        }
    }
}
