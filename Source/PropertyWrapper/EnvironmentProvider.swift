#if canImport(SwiftUI)

import Foundation
import SwiftUI

@propertyWrapper
public struct EnvironmentProvider<Value>: DynamicProperty {
    @EnvironmentObject
    private var container: ObservableResolver

    public var wrappedValue: Value {
        return container.resolve(named: name, with: arguments)
    }

    private let name: String?
    private let arguments: Arguments

    public init(named name: String? = nil,
         with arguments: Arguments = .init()) {
        self.name = name
        self.arguments = arguments
    }
}

#endif
