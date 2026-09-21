# DIKit - Dependency Injection Kit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FDIKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/NikSativa/DIKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FDIKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/NikSativa/DIKit)
[![CI](https://github.com/NikSativa/DIKit/actions/workflows/swift_macos.yml/badge.svg)](https://github.com/NikSativa/DIKit/actions/workflows/swift_macos.yml)

Swift library that allows you to use a dependency injection pattern in your project by creating a container that holds all the dependencies in one place.

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/NikSativa/DIKit.git", from: "3.2.7")
```

and link the `DIKit` product to every target that registers or resolves dependencies:

```swift
.target(name: "MyApp",
        dependencies: [
            .product(name: "DIKit", package: "DIKit")
        ])
```

There is a second product, `DIKitTesting`, for test targets only — see [Testing](#testing).

## Create container

Most recommended way to create a container is to use assemblies. Assemblies are types that conform to `Assembly` protocol and are responsible for registering dependencies in the container.
 
```swift
Container(assemblies: [
    FoundationAssembly(),
    APIAssembly(),
    DataBaseAssembly(),
    ThemeAssembly()
])
```

## SwiftUI

If you want to use DIKit in SwiftUI you can create a container in the `App` struct like this:

```swift
@main
struct MyApp: App {
    let container = Container(assemblies: [...])

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container.toObservable())
        }
    }
}

// somewhere in the code
struct ContentView: View {
    @DIObservedObject var session: Session
    
    var body: some View {
        Button("Refresh") {
            session.refresh()
        }
    }
}
```

## Shared container

If you want to use the container in the property wrappers (`Inject`, `InjectLazy`, `InjectProvider`, `InjectWrapped`) you can create a shared container like this:

```swift
let container = Container(assemblies: [...])
container.makeShared()  // <-- make container shared

// somewhere in the code
final class SomeManager {
    @InjectLazy var api: API
    
    func makeRequest() {
        api.request()
    }
}
```

There is one shared container per process, so `makeShared()` returns `false` when another container is already shared. Release it with `razeShared()`:

```swift
container.razeShared()   // releases it only when this container is the shared one
Container.razeShared()   // releases whichever container is shared
```

To give tests their own dependencies instead of the shared container, see [Testing](#testing).

## Create assembly

Most basic assembly should look like this:
```swift
final class ApplicationAssembly: Assembly {
    // list of assemblies that this assembly depends on
    var dependencies: [Assembly] { 
        return [
            AnalyticsAssembly(),
            RouterAssembly(),
            StoragesAssembly(),
            ThemeAssembly(),
            UIComponentsAssembly()
        ]
    }

    func assemble(with registrator: Registrator) {
        registrator.register(UserDefaults.self) {
            return UserDefaults.standard
        }

        registrator.register(NotificationCenter.self) {
            return NotificationCenter.default
        }

        registrator.isolatedMain.register(UIApplication.self, options: .transient) {
            return UIApplication.shared
        }

        registrator.register(BuildMode.self, entity: BuildMode.init)
        
        registrator.register(UserManager.self, options: .container, entity: UserManager.init)
    }
}
```

Use `registrator.isolatedMain` for entities that have to be created on the main actor, such as `UIApplication.shared`.

## How to resolve dependencies

At any place where you have access to container you can resolve dependencies like this:
```swift
let api: API = container.resolve()
let dataBase: DataBase = container.resolve()
```
or if container is shared you can use:
```swift
@Inject var analytics: Analytics
@InjectLazy var api: API
@InjectProvider var dataBase: DataBase
@InjectWrapped var theme: Lazy<Theme>
```
- `@Inject` resolves once, when the object that owns it is created
- `@InjectLazy` resolves on first access
- `@InjectProvider` asks the container on every access
- `@InjectWrapped` injects the `Lazy` or `Provider` wrapper itself

All four take the resolver from the shared container when the owning object is created, even the ones that resolve later.

or, in SwiftUI:
```swift
@DIObservedObject var session: Session
@DIStateObject var viewState: ReCreatedState
@DIState var filter: Filter
@DIProvider var dataBase: DataBase
```
`@DIObservedObject` and `@DIStateObject` require the resolved type to be an `ObservableObject`.

### Wrappers

`Lazy` resolves the instance on the first access to `wrappedValue` and keeps it; `Provider` asks the container on every access. Both are exposed as the projected value of the matching property wrapper — `$api` is a `Lazy<API>` and `$dataBase` is a `Provider<DataBase>` — and both can be resolved directly:

```swift
let theme: Lazy<Theme> = container.resolveWrapped()
let dataBase: Provider<DataBase> = container.resolveWrapped()
```

Both conform to `InstanceWrapper`, which requires nothing but `init(with factory: @escaping () -> Wrapped)`. Your own type conforming to it can be resolved by `resolveWrapped` and injected by `@InjectWrapped` the same way.

The SwiftUI wrappers have projected values too: `@DIState`, `@DIObservedObject` and `@DIStateObject` project a `Binding` to the resolved instance, and `@DIProvider` projects a `DIProviderOptions` carrying the name and the arguments it resolves with.

### Releasing resolve parameters

`@InjectLazy` and the SwiftUI wrappers take a `shouldCleanup` flag. When it is `true`, the wrapper forgets the name and the arguments it was created with right after the first resolve, so it does not keep the arguments alive; a later resolve — for example when SwiftUI recreates the view — then happens without them.

```swift
@InjectLazy(with: ["Bob"], shouldCleanup: true) var manager: UserManager
```

The SwiftUI wrappers default to `InjectSettings.shouldCleanupState`, `InjectSettings.shouldCleanupObservedObject` and `InjectSettings.shouldCleanupStateObject`, all `false`.

## Registration
Most basic registration looks like this:
```swift
registrator.register(BuildMode.self, entity: BuildMode.init)
```

### options

Options are made of an entity kind, an access level and an optional name.

The entity kind decides how long the container keeps the instance:
- `container` - creates a single instance and stores it in the container (like a singleton)
- `weak` - the default; resolve weak reference and if it was deallocated it will be resolved again
- `transient` - resolve new instance every time, never store it in the container

`weak` holds a reference to an object, so a value type is boxed and released right away — a struct registered as `weak` behaves like `transient`.

The access level decides whether a later registration of the same type may take over:
- `final` - the default; registering the same type again trips an assertion in debug builds, and replaces the earlier registration in release builds
- `open` - the registration is meant to be replaced, and a later registration of any access level takes over; registering an `open` entity when a `final` one already exists keeps the `final` one

Combine the parts with `+`, which accepts an `Options.EntityKind`, an `Options.AccessLevel` or a name:

```swift
registrator.register(Theme.self, options: .named("light") + .container) {
    return LightTheme()
}

registrator.register(BuildMode.self, options: .transient + .open, entity: BuildMode.init)
```

or build the value directly with `Options(accessLevel:entityKind:name:)`.

### 'Named' option
You can register multiple instances of the same type with different names and resolve them by name.

```swift
registrator.register(Theme.self, options: .named("light")) {
    return LightTheme()
}

registrator.register(Theme.self, options: .named("dark")) {
    return DarkTheme()
}
```
`.named` keeps the default `weak` kind; combine it with another kind as shown above.

and resolve it like this:
```swift
let lightTheme: Theme = container.resolve(named: "light")
let darkTheme: Theme = container.resolve(named: "dark")

@InjectLazy(named: "light") var lightTheme: Theme
@InjectLazy(named: "dark") var darkTheme: Theme
```

### '.implements'
Multiple implementations of different protocols in one class
```swift
registrator.register(UserDefaults.self) {
    return UserDefaults.standard
}
.implements(DefaultsStorage.self)
```

`implements` also takes a name and an access level, for example `.implements(AnonymousService.self, named: "anonymous")`.

A type another assembly has already registered is forwarded by looking its registration up first. Registration order matters here — the assembly that owns the registration has to run before this one:

```swift
registrator.registration(for: BuildMode.self)
    .implements(ApiBuildMode.self)
```

### Custom entity key (`EntityKeyProviding`)

The container stores every registration under a string key. By default that key is the fully qualified type name read from the type's runtime metadata through `String(reflecting:)`, which is unique and stable for the types Swift can describe.

There is one Swift-level exception: **parameterized existentials** (`any P<X>`). For such types `String(reflecting:)` returns the literal string `"<<< invalid type >>>"`, so the container falls back to the type's `ObjectIdentifier`, which keeps them apart.

Two registrations that do end up with the same key collide. In a debug build the second one trips an assertion:

```
DIKit/Container.swift:?: Fatal error: FeatureFlagStore is already registered with MyApp.FeatureFlagStore
```

and in a release build, where the assertion is compiled out, it silently replaces the first one. Give one of them a `.named` option, or conform the concrete type to `EntityKeyProviding` to pin an explicit key:

```swift
import DIKit

extension FeatureFlagStore: EntityKeyProviding {
    public static var entityKey: String {
        return "FeatureFlagStore"
    }
}
```

Only concrete types can conform. An existential such as `any P<X>` cannot, which is why the container derives its key from runtime metadata instead.

The same key is used for both registration and resolution, so every call site for that type sees the same storage bucket. Two unrelated types may deliberately share the same `entityKey` to alias one onto the other.

### Arguments
You can pass arguments to the registration block

when you don’t know the index of the argument, but you are sure that there is only one type in the arguments:
```swift
registrator.register(BlaBla.self, options: .transient) { _, args in
    return BlaBla(name: args.first())
}
```
when you know index of argument:
```swift
registrator.register(BlaBla.self, options: .transient) { _, args in
    return BlaBla(name: args[1])
}
```
and pass them when resolving:
```swift
let blaBla: BlaBla = container.resolve(with: ["Bob"])
```

`Arguments` is a small type-indexed container with the rest of the API to match:

```swift
registrator.register(BlaBla.self, options: .transient) { _, args in
    return BlaBla(name: args.first(),                          // the first String
                  age: args.resolve(Int.self, at: 1),          // the element at index 1
                  nickname: args.optionalFirst(Nickname.self)) // nil when there is none
}
```

`first()`, `resolve(at:)` and the `args[index]` subscript trap when the element is missing or has another type, so use `optionalFirst()` or `optionalResolve(at:)` when an argument may be absent. `Arguments` also exposes `count` and `isEmpty` and conforms to `Sequence`.

## UIKit

These two parts of DIKit are available on iOS only.

### View controller factory

`registerViewControllerFactory()` registers a `ViewControllerFactory` that instantiates the initial view controller of the storyboard named after the view controller type and resolves its dependencies:

```swift
let container = Container(assemblies: [...])
container.registerViewControllerFactory()

let factory: ViewControllerFactory = container.resolve()
let profile: ProfileViewController = factory.instantiate()
let pair = factory.createNavigationController(ProfileViewController.self)
```

`instantiate(_:from:bundle:)` takes an explicit storyboard name and bundle when they differ from the defaults, and `createNavigationController` returns the navigation controller together with its root.

### Self-injectable objects

An `NSObject` can resolve its own dependencies by conforming to `SelfInjectable`:

```swift
final class ProfileViewController: UIViewController, @MainActor SelfInjectable {
    private var api: API!

    func resolveDependncies(with resolver: Resolver) {
        api = resolver.resolve()
    }
}
```

`SelfInjectable` carries no actor isolation, so a `@MainActor` type such as a view controller conforms through an isolated conformance, which the Swift 6 language mode requires and Swift 6.2 introduced. A type that is not actor-isolated conforms directly.

The factory above does it for the view controllers it creates. Anywhere else, ask for it explicitly — dependencies are resolved on the first call and later calls do nothing:

```swift
controller.resolveDependnciesIfNeeded(with: resolver)
```

## Testing

`@Inject`, `@InjectLazy`, `@InjectProvider` and `@InjectWrapped` resolve from the shared container, which is a single value for the whole process. Swift Testing runs tests in parallel, so replacing the shared container from one test would leak into every test running next to it. Instead, install a resolver for the duration of a test with `InjectSettings.withResolver`. The override is bound to the current task, so tests running in parallel never see each other's resolvers.

`withResolver` and the `.resolver` trait below live in the separate `DIKitTesting` product. Add it to your test target only:

```swift
.testTarget(name: "MyAppTests",
            dependencies: [
                "MyApp",
                .product(name: "DIKitTesting", package: "DIKit")
            ])
```

The override is available only through `DIKitTesting`, so an app or an app extension that links `DIKit` alone can neither replace its dependencies nor reference the `Testing` framework.

```swift
import DIKit
import DIKitTesting
import Testing

final class FakeAPI: API {
    private(set) var requestCount = 0

    func request() {
        requestCount += 1
    }
}

@Test func makesRequest() {
    let api = FakeAPI()
    let container = Container(assemblies: [])
    container.register(API.self) {
        return api
    }

    InjectSettings.withResolver(container) {
        SomeManager().makeRequest()
    }

    #expect(api.requestCount == 1)
}
```

`withResolver` has an `async` overload for asynchronous code, and both work the same way in XCTest:

```swift
@Test func loadsProfile() async throws {
    let container = Container(assemblies: [FakeNetworkAssembly()])

    try await InjectSettings.withResolver(container) {
        try await ProfileLoader().load()
    }
}
```

### A fresh resolver for every test

Apply the `.resolver` trait to a suite or to a single test. Every test, and every case of a parameterized test, gets its own resolver from the closure, so fakes never leak from one test into another. Inside the test, `InjectSettings.resolver` returns that resolver, which is how the test reaches its fakes:

```swift
import DIKit
import DIKitTesting
import Testing

final class FakeAPIAssembly: Assembly {
    func assemble(with registrator: Registrator) {
        registrator.register(API.self, options: .container) {
            return FakeAPI()
        }
    }
}

@Suite(.resolver { Container(assemblies: [FakeAPIAssembly()]) })
struct SomeManagerTests {
    @Test func makesRequest() throws {
        SomeManager().makeRequest()

        let api = try #require(InjectSettings.resolver?.resolve(API.self) as? FakeAPI)
        #expect(api.requestCount == 1)
    }
}
```

The `.resolver` trait requires Swift 6.1 or later.

### SwiftUI

`@DIObservedObject`, `@DIStateObject`, `@DIState` and `@DIProvider` read the resolver from the environment rather than from the shared container, so hand a test or a preview its own container the same way the app does:

```swift
ContentView()
    .environmentObject(container.toObservable())
```

### Things to keep in mind

- Property wrappers capture the resolver when the object that owns them is created, even `@InjectLazy` and `@InjectProvider`, which resolve later. Create the object under test inside `withResolver`, or inside a test that uses the `.resolver` trait — an object created outside keeps the resolver it was created with.
- The override follows the current task and its child tasks. Work dispatched through GCD or `Task.detached` does not see it and falls back to the shared container.
- Do not call `makeShared()` from tests: the shared container is process-wide, so parallel tests would share it.
