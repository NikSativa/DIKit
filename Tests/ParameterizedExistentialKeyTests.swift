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
