import Foundation
import Threading

/// `Provider` is a wrapper for the factory that creates an instance of the specified type and don't store it - that means every time you access the instance property,
/// it will request instance from the container and it will create a new instance or return existing one based on registration options.
///
/// - Note: It's useful when you need to create a new instance of the object every time to solve cyclic dependencies.
public final class Provider<Wrapped>: InstanceWrapper {
    @AtomicValue
    private var factory: () -> Wrapped

    public var instance: Wrapped {
        return $factory.syncUnchecked { factory in
            return factory()
        }
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}

#if swift(>=6.0)
extension Provider: @unchecked Sendable {}
#endif
