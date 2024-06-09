import Foundation

@propertyWrapper
public struct Inject<Value> {
    public private(set) var wrappedValue: Value {
        didSet {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        self.wrappedValue = resolver.resolve(named: named, with: arguments)
    }
}
