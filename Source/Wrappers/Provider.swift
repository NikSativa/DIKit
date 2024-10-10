import Foundation

@MainActor
public final class Provider<Wrapped>: InstanceWrapper {
    private let factory: () -> Wrapped

    public var instance: Wrapped {
        return factory()
    }

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}
