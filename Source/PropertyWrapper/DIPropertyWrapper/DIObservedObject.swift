#if canImport(SwiftUI)
import Combine
import SwiftUI

/// A property wrapper type that can resolve instance of specified type by DI container which is stored in the SwiftUI environment.
///
/// It resolves specified instance on the first access and stores it inside the wrapper via `@ObservedObject` property wrapper.
///
/// - Important: It storing instance inside the wrapper by `@ObservedObject` property wrapper and handles lifecycle of the instance by SwiftUI mechanisms.
@MainActor
@propertyWrapper
public struct DIObservedObject<Value: ObservableObject>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    @ObservedObject
    private var holder: InstanceHolder<Value> = .init()
    private let parametersHolder: EnvParametersHolder

    public var wrappedValue: Value {
        return resolveInstance()
    }

    public init(named name: String? = nil, with arguments: Arguments? = nil, shouldCleanup: Bool = InjectSettings.shouldCleanupObservedObject) {
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

private final class InstanceHolder<Value: ObservableObject>: ObservableObject {
    private var instanceObserver: AnyCancellable?

    var instance: Value! {
        willSet {
            if instance != nil, newValue !== instance {
                objectWillChange.send()
            }
        }
        didSet {
            if oldValue !== instance {
                instanceObserver = instance?.objectWillChange
                    .sink { [unowned self] _ in
                        objectWillChange.send()
                    }
            }
        }
    }
}
#endif
