import DIKit

public extension InjectSettings {
    /// Runs `operation` with `resolver` taking precedence over the shared container.
    ///
    /// The override is bound to the current task and inherited by its child tasks, so concurrently running
    /// tests can each install their own resolver without affecting one another. It does not reach work
    /// dispatched through GCD or `Task.detached`.
    ///
    /// Property wrappers resolve when they are initialized, so create the object under test inside `operation`.
    ///
    /// ```swift
    /// InjectSettings.withResolver(FakeResolver()) {
    ///     let presenter = GreetingPresenter()
    ///     #expect(presenter.title == "Hello")
    /// }
    /// ```
    static func withResolver<R>(_ resolver: any Resolver, operation: () throws -> R) rethrows -> R {
        return try $scopedResolver.withValue(resolver, operation: operation)
    }

    #if compiler(>=6.4)
    /// Runs the asynchronous `operation` with `resolver` taking precedence over the shared container.
    ///
    /// See `withResolver(_:operation:)` for the scoping rules.
    nonisolated(nonsending) static func withResolver<R>(_ resolver: any Resolver,
                                                        operation: nonisolated(nonsending) () async throws -> R) async rethrows -> R {
        return try await $scopedResolver.withValue(resolver, operation: operation)
    }
    #else
    /// Runs the asynchronous `operation` with `resolver` taking precedence over the shared container.
    ///
    /// See `withResolver(_:operation:)` for the scoping rules.
    static func withResolver<R>(_ resolver: any Resolver,
                                operation: () async throws -> R,
                                isolation: isolated (any Actor)? = #isolation) async rethrows -> R {
        return try await $scopedResolver.withValue(resolver, operation: operation, isolation: isolation)
    }
    #endif
}
