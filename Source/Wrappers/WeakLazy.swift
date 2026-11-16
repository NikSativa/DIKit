import Foundation
import Threading

/// `WeakLazy` is a wrapper for the factory that creates an instance of the specified optional type and keeps only a weak reference to it.
/// It requests the instance from the container ONCE, on the first access to `wrappedValue`.
/// After the instance is deallocated, `wrappedValue` returns `nil`. The wrapper does not request the instance again.
///
/// - Note: Use it to break a cyclic dependency without a retain cycle.
/// - Important: `Wrapped` must be an `Optional` of a class instance, for example `(any API)?`. If the factory returns a value type, the wrapper stops the app with a fatal error.
@propertyWrapper
public final class WeakLazy<Wrapped: ExpressibleByNilLiteral>: InstanceWrapper {
    @AtomicValue
    private var factory: (() -> Wrapped)?
    private weak var object: AnyObject?

    public var wrappedValue: Wrapped {
        return $factory.syncUnchecked { factory in
            if let resolve = factory {
                factory = nil
                let value = resolve()
                object = Self.referencedObject(in: value)
                return value
            }

            guard let object else {
                return nil
            }

            return object as? Wrapped ?? nil
        }
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
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
