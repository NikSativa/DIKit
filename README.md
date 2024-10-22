# DIKit - Dependency Injection Kit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FDIKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/NikSativa/DIKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FNikSativa%2FDIKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/NikSativa/DIKit)
[![CI](https://github.com/NikSativa/DIKit/actions/workflows/swift_macos.yml/badge.svg)](https://github.com/NikSativa/DIKit/actions/workflows/swift_macos.yml)

Swift library that allows you to use a dependency injection pattern in your project by creating a container that holds all the dependencies in one place.

## Create container

Most recommended way to create a container is to use assemblies. Assemblies are classes that conform to `Assembly` protocol and are responsible for registering dependencies in the container.
 
```swift
Container(assemblies: [
    FoundationAssembly(),
    APIAssembli(),
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
    @DIObservedObject var api: API
    
    var body: some View {
        Button("Make request") {
            api.request()
        }
    }
}
```

## Shared container

If you want to use the container in property wrappers (InjectLazy, InjectProvider..) you can create a shared container like this:

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

        registrator.register(UIApplication.self, options: .transient) {
            return UIApplication.shared
        }

        registrator.register(BuildMode.self, entity: BuildMode.init)
        
        registrator.register(UserManager.self, options: .container, entity: UserManager.init)
    }
}
```

## How to resolve dependencies

At any place where you have access to container you can resolve dependencies like this:
```swift
let api: API = container.resolve()
let dataBase: DataBase = container.resolve()
```
or if container is shared you can use:
```swift
@InjectLazy var api: API
@InjectProvider var dataBase: DataBase
```
of SwiftUI:
```swift
@DIObservedObject var api: API
@DIStateObject var viewState: ReCreatedState
@DIProvider var dataBase: DataBase
```

## Registration
Most basic registration looks like this:
```swift
registrator.register(BuildMode.self, entity: BuildMode.init)
```

### options
- `container` - creates a single instance and stores it in the container (like a singleton)
- `weak` - resolve weak reference and if it was deallocated it will be resolved again
- `transient` - resolve new instance every time, never store it in the container

### 'Named' option
You can register multiple instances of the same type with different names and resolve them by name.

```swift
registrator.register(Theme.self, name: "light") {
    return LightTheme()
}

registrator.register(Theme.self, name: "dark") {
    return DarkTheme()
}
```
and resolve it like this:
```swift
let lightTheme: Theme = container.resolve(name: "light")
let darkTheme: Theme = container.resolve(name: "dark")

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

### Arguments
You can pass arguments to the registration block

when you don’t know the index of the argument, but you are sure that there is only one type in the arguments:
```swift
registrator.register(BlaBla.self, options: .transient) { _, args in
    return BlaBla(name: args.first()) <-- by type
}
```
when you know index of argument:
```swift
registrator.register(BlaBla.self, options: .transient) { _, args in
    return BlaBla(name: args[1]) <-- by index
}
```
