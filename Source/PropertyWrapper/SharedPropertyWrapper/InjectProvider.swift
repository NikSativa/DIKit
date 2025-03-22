import Foundation

/// `InjectProvider` is a property wrapper for the factory that creates an instance of the specified type and don't store it - that means every time you access the instance property,
/// it will request instance from the container and it will create a new instance or return existing one based on registration options.
///
/// - Important: It resolves instance from the shared container on each access.
/// - Note: It's useful when you are using shared container. See `Container.makeShared()` for more information.
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
