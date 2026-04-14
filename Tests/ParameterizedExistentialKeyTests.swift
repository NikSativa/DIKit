import DIKit
import XCTest

// MARK: - Fixtures

private protocol PrimaryAssocA<Item>: Sendable {
    associatedtype Item
    func a() -> Item
}

private protocol PrimaryAssocB<Item>: Sendable {
    associatedtype Item
    func b() -> Item
}

private struct Marker: Sendable, Equatable {
    let id: Int
}

private struct ImplA: PrimaryAssocA {
    func a() -> Marker { .init(id: 1) }
}

private struct ImplB: PrimaryAssocB {
    func b() -> Marker { .init(id: 2) }
}

// Verifies that parameterized existentials (`any P<X>`) do not collide in the
// container's key derivation. Historically `String(reflecting:)` returned
// `"<<< invalid type >>>"` for these types, causing every `any P<X>`
// registration to collapse to the same key.
final class ParameterizedExistentialKeyTests: XCTestCase {
    func test_distinct_parameterized_existentials_do_not_collide() {
        let container = Container()

        container.register((any PrimaryAssocA<Marker>).self, options: .container) { _ in
            ImplA()
        }

        container.register((any PrimaryAssocB<Marker>).self, options: .container) { _ in
            ImplB()
        }

        let a: any PrimaryAssocA<Marker> = container.resolve()
        let b: any PrimaryAssocB<Marker> = container.resolve()

        XCTAssertEqual(a.a(), Marker(id: 1))
        XCTAssertEqual(b.b(), Marker(id: 2))
    }

    func test_same_protocol_different_type_parameters_do_not_collide() {
        let container = Container()

        container.register((any PrimaryAssocA<Int>).self, options: .container) { _ in
            AnyImplA(value: 42)
        }

        container.register((any PrimaryAssocA<String>).self, options: .container) { _ in
            AnyImplA(value: "hello")
        }

        let intImpl: any PrimaryAssocA<Int> = container.resolve()
        let stringImpl: any PrimaryAssocA<String> = container.resolve()

        XCTAssertEqual(intImpl.a(), 42)
        XCTAssertEqual(stringImpl.a(), "hello")
    }

    func test_resolve_parameterized_existential_returns_registered_instance() {
        let container = Container()

        container.register((any PrimaryAssocA<Marker>).self, options: .container) { _ in
            ImplA()
        }

        let resolved: (any PrimaryAssocA<Marker>)? = container.optionalResolve()
        XCTAssertEqual(resolved?.a(), Marker(id: 1))
    }
}

private struct AnyImplA<Item: Sendable>: PrimaryAssocA {
    let value: Item
    func a() -> Item { value }
}

// MARK: - ContainerKeyProviding

private struct CustomKeyedA: ContainerKeyProviding, Equatable {
    static var containerKey: String { "dikit.tests.shared-key" }
    let id: Int
}

private struct CustomKeyedB: ContainerKeyProviding, Equatable {
    static var containerKey: String { "dikit.tests.shared-key" }
    let label: String
}

private struct CustomKeyedStable: ContainerKeyProviding, Equatable {
    static var containerKey: String { "dikit.tests.stable" }
    let value: Int
}

final class ContainerKeyProvidingTests: XCTestCase {
    func test_custom_key_is_used_for_registration_and_resolution() {
        let container = Container()

        container.register(CustomKeyedStable.self, options: .container) { _ in
            CustomKeyedStable(value: 7)
        }

        let resolved: CustomKeyedStable = container.resolve()
        XCTAssertEqual(resolved, CustomKeyedStable(value: 7))
    }

    func test_types_with_same_container_key_share_storage() {
        // Two distinct types opt into the same key — registering both
        // should hit the "already registered" assertion path, proving the
        // custom key takes precedence over the ObjectIdentifier-derived one.
        let container = Container()

        container.register(CustomKeyedA.self, options: .container + .open) { _ in
            CustomKeyedA(id: 1)
        }

        // Since both types share the same containerKey and the first
        // registration is `.open`, the second one overwrites it.
        container.register(CustomKeyedB.self, options: .container + .open) { _ in
            CustomKeyedB(label: "second")
        }

        // The shared key now points at the second registration; resolving
        // the first type via that key returns a value that isn't CustomKeyedA,
        // so the typed resolve returns nil.
        let a: CustomKeyedA? = container.optionalResolve()
        let b: CustomKeyedB? = container.optionalResolve()

        XCTAssertNil(a)
        XCTAssertEqual(b, CustomKeyedB(label: "second"))
    }
}
