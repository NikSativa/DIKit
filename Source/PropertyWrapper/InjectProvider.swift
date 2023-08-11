import Foundation

@propertyWrapper
public struct InjectProvider<Value> {
    public let projectedValue: Provider<Value>
    public private(set) var wrappedValue: Value {
        get {
            return projectedValue.instance
        }
        set {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        assert(InjectSettings.resolver != nil)
        self.projectedValue = .init(with: {
            return InjectSettings.resolver!.resolve(named: named, with: arguments)
        })
    }
}
