import Foundation

@MainActor
@propertyWrapper
public struct InjectWrapped<Value: InstanceWrapper> {
    public private(set) var wrappedValue: Value {
        didSet {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments? = nil) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        self.wrappedValue = resolver.resolveWrapped(named: named, with: arguments)
    }
}
