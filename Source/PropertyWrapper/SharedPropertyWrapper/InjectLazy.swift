import Foundation

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

    public init(named: String? = nil, with arguments: Arguments? = nil) {
        guard let resolver = InjectSettings.resolver else {
            fatalError("Container is not shared")
        }

        let holder: EnvParametersHolder = .init()
        holder.name = named
        holder.arguments = arguments

        self.projectedValue = .init(with: { [holder] in
            defer {
                holder.cleanup()
            }
            return resolver.resolve(named: holder.name, with: holder.arguments)
        })
    }
}
