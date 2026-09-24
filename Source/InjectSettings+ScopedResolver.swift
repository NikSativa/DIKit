#if DEBUG
public extension InjectSettings {
    /// Runs `operation` with `resolver` taking precedence over the shared container.
    ///
    /// Available in Debug builds only, as the `Testing` SPI: call it from files that import DIKit with
    /// `@_spi(Testing) import DIKit`. Code that imports DIKit normally does not see it, and Release builds do not contain it.
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
    ///
    /// - Important: The override reaches only code that uses the same copy of DIKit as the caller.
    ///   When the code under test lives in an app that hosts the tests, the test bundle has to use the app's copy:
    ///   link the same DIKit product into both, with `DIKitDynamic` guaranteeing a single copy, and leave `DIKitTesting`
    ///   out of that bundle, because it links DIKit statically and brings a copy of its own. Otherwise the app reads
    ///   the resolver from its own copy: the object under test resolves from the app's container and the fakes are
    ///   never called. In LLDB, `image lookup -r -s scopedResolver` shows every image that carries a copy.
    @_spi(Testing)
    static func withResolver<R>(_ resolver: any Resolver, operation: () throws -> R) rethrows -> R {
        return try $scopedResolver.withValue(resolver, operation: operation)
    }

    #if compiler(>=6.4)
    /// Runs the asynchronous `operation` with `resolver` taking precedence over the shared container.
    ///
    /// See `withResolver(_:operation:)` for availability, the scoping rules and testing code in a host app.
    @_spi(Testing)
    nonisolated(nonsending) static func withResolver<R>(_ resolver: any Resolver,
                                                        operation: nonisolated(nonsending) () async throws -> R) async rethrows -> R {
        return try await $scopedResolver.withValue(resolver, operation: operation)
    }
    #else
    /// Runs the asynchronous `operation` with `resolver` taking precedence over the shared container.
    ///
    /// See `withResolver(_:operation:)` for availability, the scoping rules and testing code in a host app.
    @_spi(Testing)
    static func withResolver<R>(_ resolver: any Resolver,
                                operation: () async throws -> R,
                                isolation: isolated (any Actor)? = #isolation) async rethrows -> R {
        return try await $scopedResolver.withValue(resolver, operation: operation, isolation: isolation)
    }
    #endif
}
#endif
