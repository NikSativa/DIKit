import Foundation

public protocol InstanceWrapper {
    associatedtype Wrapped

    typealias Factory = () -> Wrapped
    init(with factory: @escaping Factory)
}
