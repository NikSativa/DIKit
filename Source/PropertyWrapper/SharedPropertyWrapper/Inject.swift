import Foundation
import Threading

/// `Inject` is a property wrapper for the factory that creates an instance of the specified type and store it - that means every time you access the instance property it returns existing one stored inside wrapper.
///
/// - Important: It resolves instance from the shared container on initialisation.
/// - Note: It's useful when you are using shared container. See `Container.makeShared()` for more information.
@propertyWrapper
public struct Inject<Value> {
    public private(set) var wrappedValue: Value {
        didSet {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments? = nil) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        self.wrappedValue = resolver.resolve(named: named, with: arguments)
    }
}
