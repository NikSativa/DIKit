import Foundation

public enum InjectSettings {
    /// General container. It is used to resolve dependencies in the application according to your requirements.
    /// Make sure that you have called `container.makeShared()` before using it and sure that it called only once.
    public internal(set) nonisolated(unsafe) static var container: Container? {
        didSet {
            assert(oldValue == nil || container == nil, "Container is already registered")
        }
    }

    /// Default setting for ```DIObservedObject``` property wrapper
    /// - Warning:  override it on your own risk
    public nonisolated(unsafe) static var shouldCleanupObservedObject: Bool = false
    /// Default setting for ```DIState``` property wrapper
    /// - Warning:  override it on your own risk
    public nonisolated(unsafe) static var shouldCleanupState: Bool = false
    /// Default setting for ```DIStateObject``` property wrapper
    /// - Warning:  override it on your own risk
    public nonisolated(unsafe) static var shouldCleanupStateObject: Bool = false

    @TaskLocal
    private static var scopedResolver: (any Resolver)?

    /// Resolver used by the `Inject`, `InjectLazy`, `InjectProvider` and `InjectWrapped` property wrappers.
    ///
    /// Returns the resolver installed by `withResolver(_:operation:)` for the current task when there is one,
    /// otherwise the shared container. Make sure that you have called `container.makeShared()` before relying on the shared container.
    public static var resolver: Resolver? {
        return scopedResolver ?? container
    }

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
    public static func withResolver<R>(_ resolver: any Resolver, operation: () throws -> R) rethrows -> R {
        return try $scopedResolver.withValue(resolver, operation: operation)
    }

    #if compiler(>=6.4)
    /// Runs the asynchronous `operation` with `resolver` taking precedence over the shared container.
    ///
    /// See `withResolver(_:operation:)` for the scoping rules.
    public nonisolated(nonsending) static func withResolver<R>(_ resolver: any Resolver,
                                                               operation: nonisolated(nonsending) () async throws -> R) async rethrows -> R {
        return try await $scopedResolver.withValue(resolver, operation: operation)
    }
    #else
    /// Runs the asynchronous `operation` with `resolver` taking precedence over the shared container.
    ///
    /// See `withResolver(_:operation:)` for the scoping rules.
    public static func withResolver<R>(_ resolver: any Resolver,
                                       operation: () async throws -> R,
                                       isolation: isolated (any Actor)? = #isolation) async rethrows -> R {
        return try await $scopedResolver.withValue(resolver, operation: operation, isolation: isolation)
    }
    #endif
}
