#if os(iOS) && canImport(UIKit)
@_spi(Testing) import DIKit
import Foundation
import Testing

private final class InjectableObject: NSObject, SelfInjectable {
    private(set) var resolveCount = 0

    func resolveDependencies(with resolver: Resolver) {
        resolveCount += 1
    }
}

struct SelfInjectableTests {
    @Test
    func resolvesDependenciesOnlyOnce() {
        let object = InjectableObject()
        let container = Container(assemblies: [])

        object.resolveDependenciesIfNeeded(with: container)
        object.resolveDependenciesIfNeeded(with: container)

        #expect(object.resolveCount == 1)
    }

    @Test
    func keepsTheTagAndResolvesDependenciesWhenTheTagIsSet() {
        let object = InjectableObject()

        InjectSettings.withResolver(Container(assemblies: [])) {
            object.setValue("profile", forKey: "dipTag")
        }

        #expect(object.value(forKey: "dipTag") as? String == "profile")
        #expect(object.resolveCount == 1)
    }
}
#endif
