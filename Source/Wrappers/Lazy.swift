import Foundation

/// `Lazy` is a wrapper for the factory that creates an instance of the specified type and store it - that means every time you access the instance property,
/// it will request instance from the container ONCE and return existing one stored inside wrapper.
///
/// - Note: It's useful when you need to create a new instance of the object every time to solve cyclic dependencies.
/// - Note: If the main thread reads the value while a background thread runs the factory and waits for the main thread, the main thread runs the factory too. Both get the value that the wrapper stores first.
@propertyWrapper
public final class Lazy<Wrapped>: InstanceWrapper {
    private let creationLock = CreationLock()
    private var factory: (() -> Wrapped)?
    private var innerValue: Wrapped?

    public var wrappedValue: Wrapped {
        return creationLock.resolve(cached: {
            return innerValue
        }, create: {
            return factory!()
        }, store: { created in
            if let innerValue {
                return innerValue
            }
            innerValue = created
            factory = nil
            return created
        })
    }

    @available(*, deprecated, renamed: "wrappedValue")
    public var instance: Wrapped {
        wrappedValue
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}

extension Lazy: @unchecked Sendable {}
