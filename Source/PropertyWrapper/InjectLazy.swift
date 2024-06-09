import Foundation

@propertyWrapper
public struct InjectLazy<Value> {
    public let projectedValue: Lazy<Value>
    public private(set) var wrappedValue: Value {
        get {
            return projectedValue.instance
        }
        set {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        self.projectedValue = .init(with: {
            return resolver.resolve(named: named, with: arguments)
        })
    }
}
