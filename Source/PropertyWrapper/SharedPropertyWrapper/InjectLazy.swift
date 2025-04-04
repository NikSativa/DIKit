import Foundation

/// `InjectLazy` is a property wrapper for the factory that creates an instance of the specified type and store it - that means every time you access the instance property,
/// it will request instance from the container ONCE it was accessed and then return existing one stored inside wrapper.
///
/// - Important: It resolves instance from the shared container on ONCE it was accessed _(not on initialisation)_.
/// - Note: It's useful when you are using shared container. See `Container.makeShared()` for more information.
@propertyWrapper
public struct InjectLazy<Value> {
    public private(set) var wrappedValue: Value {
        get {
            return projectedValue.instance
        }
        set {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public let projectedValue: Lazy<Value>

    public init(named: String? = nil, with arguments: Arguments? = nil, shouldCleanup: Bool = false) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        let holder: EnvParametersHolder = .init(name: named, arguments: arguments, shouldCleanup: shouldCleanup)
        self.projectedValue = .init(with: { [holder] in
            defer {
                holder.cleanupIfNeeded()
            }
            return resolver.resolve(named: holder.name, with: holder.arguments)
        })
    }
}
