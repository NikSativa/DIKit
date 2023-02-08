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

@propertyWrapper
public struct InjectLazy<Value> {
    public let projectedValue: Lazy<Value>
    public private(set) var wrappedValue: Value {
        get {
            return projectedValue.instance
        }
        set {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        assert(InjectSettings.resolver != nil)
        self.projectedValue = InjectSettings.resolver!.resolve(named: named, with: arguments)
    }
}

@propertyWrapper
public struct InjectProvider<Value> {
    public let projectedValue: Provider<Value>
    public private(set) var wrappedValue: Value {
        get {
            return projectedValue.instance
        }
        set {
            assertionFailure("<Inject> setter is unavailable")
        }
    }

    public init(named: String? = nil, with arguments: Arguments = .init()) {
        assert(InjectSettings.resolver != nil)
        self.projectedValue = InjectSettings.resolver!.resolve(named: named, with: arguments)
    }
}
