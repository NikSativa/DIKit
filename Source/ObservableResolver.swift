import Foundation

/// `ObservableResolver` is a wrapper for the resolver that can be observed by SwiftUI views in the environment.
///
/// ```swift
/// @main
/// struct MyApp: App {
///    let container = Container(assemblies: [...])
///
///    var body: some Scene {
///        WindowGroup {
///            ContentView()
///                .environmentObject(container.toObservable())
///        }
///    }
/// }
///
/// // somewhere in the code
/// struct ContentView: View {
///    @DIObservedObject var api: API
///
///    var body: some View {
///        Button("Make request") {
///            api.request()
///        }
///    }
/// }
/// ```
@MainActor
public final class ObservableResolver: Resolver, ObservableObject {
    private let original: Resolver

    init(_ original: Resolver) {
        self.original = original
    }

    public func optionalResolve<T>(type: T.Type, named: String?, with arguments: Arguments) -> T? {
        return original.optionalResolve(type, named: named, with: arguments)
    }
}

public extension Resolver {
    /// Returns an observable resolver that can be observed by SwiftUI views in the environment.
    func toObservable() -> ObservableResolver {
        return ObservableResolver(self)
    }
}
