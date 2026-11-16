import Foundation

/// `InjectWeakLazy` is a property wrapper for the factory that creates an instance of the specified optional type and keeps only a weak reference to it.
/// It requests the instance from the shared container ONCE, on the first access _(not on initialization)_.
/// After the instance is deallocated, the property returns `nil`. The wrapper does not request the instance again.
///
/// - Note: Use it to break a cyclic dependency without a retain cycle. See `WeakLazy` for more information.
/// - Note: It's useful when you are using shared container. See `Container.makeShared()` for more information.
@propertyWrapper
public struct InjectWeakLazy<Value: ExpressibleByNilLiteral> {
    public var wrappedValue: Value {
        return projectedValue.wrappedValue
    }

    public let projectedValue: WeakLazy<Value>

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
