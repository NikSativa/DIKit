import Foundation

@MainActor
@propertyWrapper
public struct InjectProvider<Value> {
    public private(set) var wrappedValue: Value {
        get {
            return projectedValue.instance
        }
        set {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public let projectedValue: Provider<Value>

    public init(named: String? = nil, with arguments: Arguments? = nil) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        self.projectedValue = .init(with: {
            return resolver.resolve(named: named, with: arguments)
        })
    }
}
