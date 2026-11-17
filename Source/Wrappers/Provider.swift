import Foundation

/// `Provider` is a wrapper for the factory that creates an instance of the specified type and don't store it - that means every time you access the instance property,
/// it will request instance from the container and it will create a new instance or return existing one based on registration options.
///
/// - Note: It's useful when you need to create a new instance of the object every time to solve cyclic dependencies.
/// - Note: The wrapper runs the factory for one caller at a time. If the factory waits for the main thread, the main thread can run the factory during that wait.
@propertyWrapper
public final class Provider<Wrapped>: InstanceWrapper {
    private let creationLock = CreationLock()
    private let factory: () -> Wrapped

    public var wrappedValue: Wrapped {
        return creationLock.run(factory)
    }

    @available(*, deprecated, renamed: "wrappedValue")
    public var instance: Wrapped {
        wrappedValue
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}

extension Provider: @unchecked Sendable {}
