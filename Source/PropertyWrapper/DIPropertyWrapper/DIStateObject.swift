#if canImport(SwiftUI)
import Combine
import SwiftUI

@propertyWrapper
public struct DIStateObject<Value: ObservableObject>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    @StateObject
    private var holder: InstanceHolder<Value> = .init()
    private let parametersHolder: EnvParametersHolder = .init()

    public var wrappedValue: Value {
        return resolveInstance()
    }

    public init(named name: String? = nil,
                with arguments: Arguments? = nil) {
        parametersHolder.name = name
        parametersHolder.arguments = arguments
    }

    public var projectedValue: Binding<Value> {
        resolveInstance()
        return $holder.instance
    }

    @discardableResult
    private func resolveInstance() -> Value {
        if let instance = holder.instance {
            return instance
        }

        let instance: Value = container.resolve(named: parametersHolder.name, with: parametersHolder.arguments)
        holder.instance = instance
        parametersHolder.cleanup()
        return instance
    }
}

private final class InstanceHolder<Value: ObservableObject>: ObservableObject {
    private var observers: Set<AnyCancellable> = []

    var instance: Value! {
        didSet {
            if oldValue !== instance {
                assert(observers.isEmpty, "Subscribed to `objectWillChange` multiple times. Should never happen.")
                observers = []
                instance.objectWillChange.sink { [unowned self] _ in
                    objectWillChange.send()
                }.store(in: &observers)
            }
        }
    }
}
#endif
