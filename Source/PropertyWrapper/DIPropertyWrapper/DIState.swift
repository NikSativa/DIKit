#if canImport(SwiftUI)
import Combine
import SwiftUI

@propertyWrapper
public struct DIState<Value>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    @State
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

private final class InstanceHolder<Value>: ObservableObject {
    var instance: Value! {
        didSet {
            if oldValue != nil {
                objectWillChange.send()
            }
        }
    }
}
#endif
