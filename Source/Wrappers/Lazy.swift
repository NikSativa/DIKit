import Foundation
import Threading

/// `Lazy` is a wrapper for the factory that creates an instance of the specified type and store it - that means every time you access the instance property,
/// it will request instance from the container ONCE and return existing one stored inside wrapper.
///
/// - Note: It's useful when you need to create a new instance of the object every time to solve cyclic dependencies.
@propertyWrapper
public final class Lazy<Wrapped>: InstanceWrapper {
    @AtomicValue
    private var factory: (() -> Wrapped)!

    private var innerValue: Wrapped?
    public private(set) lazy var wrappedValue: Wrapped = {
        let factory = $factory.syncUnchecked { factory in
            if let innerValue {
                return innerValue
            }

            let value = factory!()
            innerValue = value
            factory = nil

            return value
        }
        return factory
    }()

    @available(*, deprecated, renamed: "wrappedValue")
    public var instance: Wrapped {
        wrappedValue
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}

#if swift(>=6.0)
extension Lazy: @unchecked Sendable {}
#endif
