#if canImport(SwiftUI)
import Combine
import SwiftUI

/// A property wrapper type that can resolve instance of specified type by DI container which is stored in the SwiftUI environment.
///
/// It resolves the instance on the first access and keeps it for the lifetime of the view, as `@State` does.
///
/// - Important: SwiftUI handles the lifecycle of the instance. A write through the projected `Binding` redraws the view.
@MainActor
@propertyWrapper
public struct DIState<Value>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    @StateObject
    private var holder: InstanceHolder<Value> = .init()
    private let parametersHolder: EnvParametersHolder

    public var wrappedValue: Value {
        return resolveInstance()
    }

    public init(named name: String? = nil, with arguments: Arguments? = nil, shouldCleanup: Bool = InjectSettings.shouldCleanupState) {
        self.parametersHolder = .init(name: name, arguments: arguments, shouldCleanup: shouldCleanup)
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
        parametersHolder.cleanupIfNeeded()
        return instance
    }
}

private final class InstanceHolder<Value>: ObservableObject {
    var instance: Value! {
        willSet {
            if instance != nil {
                objectWillChange.send()
            }
        }
    }
}
#endif
