import Foundation

/// `InjectWrapped` is a property wrapper for the factory that creates an `InstanceWrapper` of the specified type and store it.
///
/// - Important: It resolves wrapper _(not instance)_ from the shared container on initialisation.
/// - Note: It's useful when you are using shared container. See `Container.makeShared()` for more information.
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
