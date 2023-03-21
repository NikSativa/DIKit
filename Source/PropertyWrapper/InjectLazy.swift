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
        assert(InjectSettings.resolver != nil)
        self.projectedValue = InjectSettings.resolver!.resolve(named: named, with: arguments)
    }
}
