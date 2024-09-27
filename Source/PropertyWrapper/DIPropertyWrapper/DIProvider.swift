#if canImport(SwiftUI)
import Foundation
import SwiftUI

public struct DIProviderOptions {
    public let name: String?
    public let arguments: Arguments?
}

@MainActor @propertyWrapper
public struct DIProvider<Value>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    private let parametersHolder: EnvParametersHolder = .init()

    public var wrappedValue: Value {
        return container.resolve(named: parametersHolder.name, with: parametersHolder.arguments)
    }

    public init(named name: String? = nil,
                with arguments: Arguments? = nil) {
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
