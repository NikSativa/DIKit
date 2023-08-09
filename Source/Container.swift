import Foundation

public final class Container {
    private typealias Storyboardable = (Any, Resolver) -> Void
    private var storages: [String: Storage] = [:]

    public init(assemblies: [Assembly],
                shared: Bool = true) {
        let allAssemblies = assemblies.flatMap(\.allDependencies).unified()
        for assembly in allAssemblies {
            assembly.assemble(with: self)
        }

        if shared {
            makeShared()
        }

        #if os(iOS)
        registerAny(ViewControllerFactory.self) { [unowned self] _, _ in
            Impl.ViewControllerFactory(container: self)
        }
        #endif
    }

    deinit {
        if InjectSettings.container === self {
            InjectSettings.container = nil
        }
    }

    public convenience init(assemblies: Assembly..., shared: Bool = false) {
        self.init(assemblies: assemblies, shared: shared)
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
    @discardableResult
    public func register<T>(_ type: T.Type,
                            options: Options,
                            entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
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

    @discardableResult
    public func registerAny<T>(_ type: T.Type,
                               name: String?,
                               accessLevel: Options.AccessLevel,
                               entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
        let key = key(type, name: name)

        if let found = storages[key] {
            switch found.accessLevel {
            case .final:
                assertionFailure("\(type) is already registered with \(key)")
            case .open:
                break
            }
        }

        let storage: Storage = ContainerStorage(accessLevel: .open, generator: entity)
        storages[key] = storage
        return Forwarder(container: self, storage: storage)
    }

    public func registrationOfAny(for type: (some Any).Type,
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
    func registerAny(_ type: (some Any).Type, named: String?, storage: Storage) {
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

    func register(_ type: (some AnyObject).Type, named: String?, storage: Storage) {
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

extension Container /* Storyboardable */ {
    private func makeShared() {
        assert(InjectSettings.container.isNil, "storyboard handler was registered twice")
        InjectSettings.container = self
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
