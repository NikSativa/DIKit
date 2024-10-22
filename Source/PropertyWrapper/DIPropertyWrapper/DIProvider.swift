#if canImport(SwiftUI)
import Foundation
import SwiftUI

/// Options for resolving instance by `DIProvider` property wrapper.
@MainActor
public struct DIProviderOptions {
    /// Name of the instance to resolve.
    public let name: String?
    /// Arguments for resolving instance.
    public let arguments: Arguments?
}

/// A property wrapper type that can resolve instance of specified type by DI container which is stored in the SwiftUI environment.
///
/// It resolves specified instance on each access and NOT stores it inside the wrapper.
/// You can change resolving parameters by changing `projectedValue`_(ex. $variableName)_
///
/// - Important: It not storing instance inside the wrapper and resolve it each time when it accessed.
@MainActor
@propertyWrapper
public struct DIProvider<Value>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    private let parametersHolder: EnvParametersHolder = .init()

    public var wrappedValue: Value {
        return container.resolve(named: parametersHolder.name, with: parametersHolder.arguments)
    }

    public init(named name: String? = nil, with arguments: Arguments? = nil) {
        parametersHolder.name = name
        parametersHolder.arguments = arguments
    }

    public var projectedValue: DIProviderOptions {
        get {
            return .init(name: parametersHolder.name, arguments: parametersHolder.arguments)
        }
        set {
            parametersHolder.name = newValue.name
            parametersHolder.arguments = newValue.arguments
        }
    }
}
#endif
