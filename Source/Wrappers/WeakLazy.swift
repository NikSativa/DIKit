import Foundation

/// `WeakLazy` is a wrapper for the factory that creates an instance of the specified optional type and keeps only a weak reference to it.
/// It requests the instance from the container ONCE, on the first access to `wrappedValue`.
/// After the instance is deallocated, `wrappedValue` returns `nil`. The wrapper does not request the instance again.
///
/// - Note: Use it to break a cyclic dependency without a retain cycle.
/// - Note: If the main thread reads the value while a background thread runs the factory and waits for the main thread, the main thread runs the factory too. Both get the value that the wrapper stores first.
/// - Important: `Wrapped` must be an `Optional` of a class instance, for example `(any API)?`. If the factory returns a value type, the wrapper stops the app with a fatal error.
@propertyWrapper
public final class WeakLazy<Wrapped: ExpressibleByNilLiteral>: InstanceWrapper {
    private let creationLock = CreationLock()
    private var factory: (() -> Wrapped)?
    private weak var object: AnyObject?

    public var wrappedValue: Wrapped {
        return creationLock.resolve(cached: {
            guard factory == nil else {
                return Optional<Wrapped>.none
            }
            return referencedValue()
        }, create: {
            return factory!()
        }, store: { created in
            guard factory != nil else {
                return referencedValue()
            }
            factory = nil
            object = Self.referencedObject(in: created)
            return created
        })
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }

    private func referencedValue() -> Wrapped {
        guard let object else {
            return nil
        }
        return object as? Wrapped ?? nil
    }

    private static func referencedObject(in value: Wrapped) -> AnyObject? {
        let mirror = Mirror(reflecting: value)
        guard mirror.displayStyle == .optional else {
            fatalError("WeakLazy<\(Wrapped.self)> needs an Optional type")
        }

        guard let instance = mirror.children.first?.value else {
            return nil
        }

        guard type(of: instance) is AnyClass else {
            fatalError("WeakLazy<\(Wrapped.self)> keeps only a class instance, but the factory returned \(type(of: instance))")
        }

        return instance as AnyObject
    }
}

extension WeakLazy: @unchecked Sendable {}
