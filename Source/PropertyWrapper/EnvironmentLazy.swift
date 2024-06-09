#if canImport(SwiftUI)
import Foundation
import SwiftUI

@propertyWrapper
public struct EnvironmentLazy<Value>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver
    private var holder: Holder<Value> = .init()

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
}

private final class Holder<Value>: ObservableObject {
    var instance: Value?
}
#endif
