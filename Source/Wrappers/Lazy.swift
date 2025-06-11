import Foundation
import Threading

/// `Lazy` is a wrapper for the factory that creates an instance of the specified type and store it - that means every time you access the instance property,
/// it will request instance from the container ONCE and return existing one stored inside wrapper.
///
/// - Note: It's useful when you need to create a new instance of the object every time to solve cyclic dependencies.
public final class Lazy<Wrapped>: InstanceWrapper {
    @AtomicValue
    private var factory: (() -> Wrapped)!

    public private(set) lazy var instance: Wrapped = {
        let factory = $factory.syncUnchecked { factory in
            defer {
                factory = nil
            }
            return factory
        }
        return factory!()
    }()

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}

#if swift(>=6.0)
extension Lazy: @unchecked Sendable {}
#endif
