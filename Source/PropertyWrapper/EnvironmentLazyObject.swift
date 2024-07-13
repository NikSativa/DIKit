#if canImport(SwiftUI)
import Combine
import SwiftUI

@propertyWrapper
public struct EnvironmentLazyObject<Value: ObservableObject>: DynamicProperty {
    @EnvironmentObject private var container: ObservableResolver
    @ObservedObject private var holder: Holder<Value> = .init()

    public var wrappedValue: Value {
        if let instance = holder.instance {
            return instance
        }

        let instance: Value = container.resolve(named: name, with: arguments)
        holder.instance = instance
        return instance
    }

    private let name: String?
    private let arguments: Arguments

    public init(named name: String? = nil,
                with arguments: Arguments = .init()) {
        self.name = name
        self.arguments = arguments
    }

    public var projectedValue: Binding<Value> {
        assert(holder.instance != nil, "`projectedValue` is not available while the `wrappedValue` is not initialized. Should never happen.")
        return $holder.instance
    }
}

private final class Holder<Value: ObservableObject>: ObservableObject {
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
