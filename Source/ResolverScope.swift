#if canImport(Testing) && compiler(>=6.1)
import Testing

/// A test trait that installs a freshly created resolver for each test it applies to.
///
/// Every test case receives its own resolver from `makeResolver`, so stubs and recorded calls never leak
/// between tests, including tests that run in parallel. Applied to a suite, the trait reaches every test in it.
///
/// ```swift
/// @Suite(.resolver { FakeResolver() })
/// struct GreetingPresenterTests {
///     @Test func showsGreeting() {
///         #expect(GreetingPresenter().title == "Hello")
///     }
/// }
/// ```
public struct ResolverScope: TestTrait, SuiteTrait, TestScoping {
    private let makeResolver: @Sendable () -> any Resolver

    public var isRecursive: Bool {
        return true
    }

    fileprivate init(makeResolver: @escaping @Sendable () -> any Resolver) {
        self.makeResolver = makeResolver
    }

    public func provideScope(for test: Test,
                             testCase: Test.Case?,
                             performing function: @Sendable () async throws -> Void) async throws {
        try await InjectSettings.withResolver(makeResolver(), operation: function)
    }
}

public extension Trait where Self == ResolverScope {
    /// Installs a resolver created by `makeResolver` for each test the trait applies to.
    static func resolver(_ makeResolver: @escaping @Sendable () -> any Resolver) -> Self {
        return ResolverScope(makeResolver: makeResolver)
    }
}
#endif
