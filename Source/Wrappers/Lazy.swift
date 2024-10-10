import Foundation

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
