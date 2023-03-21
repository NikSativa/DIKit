import Foundation

@propertyWrapper
public struct Inject<Value> {
    public private(set) var wrappedValue: Value {
        didSet {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        assert(InjectSettings.resolver != nil)
        self.wrappedValue = InjectSettings.resolver!.resolve(named: named, with: arguments)
    }
}
