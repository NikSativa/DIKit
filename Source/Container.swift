import Foundation

@MainActor
public final class Container {
    private typealias Storyboardable = (Any, Resolver) -> Void
    private var storages: [String: Storage] = [:]

    @MainActor
    public init(assemblies: [Assembly]) {
        let allAssemblies = assemblies.flatMap(\.allDependencies).unified()
        for assembly in allAssemblies {
            assembly.assemble(with: self)
        }
    }

    @MainActor
    public convenience init(assemblies: Assembly...) {
        self.init(assemblies: assemblies)
    }

    deinit {
        if InjectSettings.container === self {
            InjectSettings.container = nil
        }
    }

    #if os(iOS) && canImport(UIKit)
    public func registerViewControllerFactory() {
        register(ViewControllerFactory.self, options: .transient) { resolver, _ in
            Impl.ViewControllerFactory(resolver: resolver)
        }
    }
    #endif

    /// Register shared container. Return `true` when correctly registered, otherwise `false`
    /// Manually access to shared container is not recommended, but it's possible `InjectSettings.container`
    @discardableResult
    public func makeShared() -> Bool {
        if InjectSettings.container.isNil {
            InjectSettings.container = self
            return true
        }
        return false
    }

    /// Unregister shared container. if it's the same instance return `true` otherwise `false`
    @discardableResult
    public func razeShared() -> Bool {
        if InjectSettings.container === self {
            InjectSettings.container = nil
            return true
        }
        return false
    }

    /// Unregister shared container. No matter what instance is registered...
    public static func razeShared() {
        InjectSettings.container = nil
    }

    private func key(_ type: some Any, name: String?) -> String {
        let key = String(reflecting: type).normalized
        return name.map { key + "_" + $0 } ?? key
    }

    private func key(_ obj: Any, name: String?) -> String {
        let key = String(reflecting: type(of: obj)).normalized
        return name.map { key + "_" + $0 } ?? key
    }
}

// MARK: - Registrator

extension Container: Registrator {
    // MARK: - AnyObject

    /// register classes
    @discardableResult
    public func register<T>(_ type: T.Type,
                            options: Options,
                            entity: @MainActor @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        let key = key(type, name: options.name)

        if let found = storages[key] {
            switch (found.accessLevel, options.accessLevel) {
            case (.final, .final):
                assertionFailure("\(type) is already registered with \(key)")
            case (.final, .open):
                // ignore `open` due to final realisation
                return Forwarder(container: self, storage: found)
            case (.open, _):
                break
            }
        }

        let storage: Storage
        let accessLevel = options.accessLevel
        switch options.entityKind {
        case .container:
            storage = ContainerStorage(accessLevel: accessLevel, generator: entity)
        case .transient:
            storage = TransientStorage(accessLevel: accessLevel, generator: entity)
        case .weak:
            storage = WeakStorage(accessLevel: accessLevel, generator: entity)
        }

        storages[key] = storage
        return Forwarder(container: self, storage: storage)
    }

    public func registration(for type: (some Any).Type,
                             name: String?) -> Forwarding {
        let key = key(type, name: name)

        guard let storage = storages[key] else {
            fatalError("can't resolve dependency of <\(type)>")
        }

        return Forwarder(container: self, storage: storage)
    }
}

// MARK: - ForwardRegistrator

extension Container: ForwardRegistrator {
    func register(_ type: (some Any).Type, named: String?, storage: Storage) {
        let key = key(type, name: named)

        if let found = storages[key] {
            switch found.accessLevel {
            case .final:
                assertionFailure("\(type) is already registered with \(key)")
            case .open:
                break
            }
        }

        storages[key] = storage
    }
}

// MARK: - Resolver

extension Container: Resolver {
    public func optionalResolve<T>(_ type: T.Type, named: String?, with arguments: Arguments) -> T? {
        let key = key(type, name: named)
        if let storage = storages[key],
           let resolved = storage.resolve(with: self, arguments: arguments) as? T {
            return resolved
        }
        return nil
    }
}

private extension String {
    var unwrapped: String {
        if hasPrefix("Swift.Optional<") {
            return String(dropFirst("Swift.Optional<".count).dropLast(1))
        }
        return self
    }

    var normalized: String {
        return components(separatedBy: ".").filter { $0 != "Type" && $0 != "Protocol" }.joined(separator: ".").unwrapped
    }
}

private extension Optional {
    var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
}

private extension [Assembly] {
    @MainActor
    func unified() -> [Element] {
        var keys: Set<String> = []
        let unified = filter {
            let key = $0.id
            if keys.contains(key) {
                return false
            }
            keys.insert(key)
            return true
        }
        return unified
    }
}

private extension Assembly {
    var allDependencies: [Assembly] {
        return [self] + dependencies + dependencies.flatMap(\.allDependencies)
    }
}
