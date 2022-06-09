import Foundation

public final class Lazy<Wrapped>: InstanceWrapper {
    private var factory: Lazy.Factory?

    public lazy var instance: Wrapped = {
        defer {
            factory = nil
        }
        return factory!()
    }()

    public init(with factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
}
