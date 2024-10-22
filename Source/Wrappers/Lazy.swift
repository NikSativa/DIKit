import Foundation

/// `Lazy` is a wrapper for the factory that creates an instance of the specified type and store it - that means every time you access the instance property,
/// it will request instance from the container ONCE and return existing one stored inside wrapper.
///
/// - Note: It's useful when you need to create a new instance of the object every time to solve cyclic dependencies.
@MainActor
public final class Lazy<Wrapped>: InstanceWrapper {
    private var factory: (() -> Wrapped)!

    @MainActor
    public private(set) lazy var instance: Wrapped = {
        let value = factory()
        factory = nil
        return value
    }()

    @MainActor
    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}
