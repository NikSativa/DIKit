import Foundation

/// `InstanceWrapper` is a protocol for the your custom property wrappers that creates an instance of the specified type.
@MainActor
public protocol InstanceWrapper {
    associatedtype Wrapped

    @MainActor
    init(with factory: @escaping () -> Wrapped)
}
