import Foundation

/// `InstanceWrapper` is a protocol for the your custom property wrappers that creates an instance of the specified type.
public protocol InstanceWrapper: Sendable {
    associatedtype Wrapped
    init(with factory: @escaping () -> Wrapped)
}
