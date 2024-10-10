import Foundation

@MainActor
public protocol InstanceWrapper {
    associatedtype Wrapped

    @MainActor
    init(with factory: @escaping () -> Wrapped)
}
