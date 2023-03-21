import Foundation

@propertyWrapper
public struct InjectWrapped<Value: InstanceWrapper> {
    public private(set) var wrappedValue: Value {
        didSet {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        assert(InjectSettings.resolver != nil)
        self.wrappedValue = InjectSettings.resolver!.resolveWrapped(named: named, with: arguments)
    }
}
