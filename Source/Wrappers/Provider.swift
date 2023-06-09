import Foundation

public final class Provider<Wrapped>: InstanceWrapper {
    private let factory: Provider.Factory

    public var instance: Wrapped {
        return factory()
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}
