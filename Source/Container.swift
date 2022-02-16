import Foundation

public final class Container {
    private typealias Storyboardable = (Any, Resolver) -> Void

    private var storages: [String: Storage] = [:]
    private var storyboards: [String: Storyboardable] = [:]
    private let strongRefCycle: Bool

    public init(assemblies: [Assembly],
                storyboardable: Bool = false,
                strongRefCycle: Bool = false) {
        self.strongRefCycle = strongRefCycle

        let allAssemblies = assemblies.flatMap(\.allDependencies).unified()
        for assembly in allAssemblies {
            assembly.assemble(with: self)
        }

        if storyboardable {
            makeStoryboardable()
        }

        #if os(iOS)
        register(ViewControllerFactory.self) { [unowned self] _, _ in
            Impl.ViewControllerFactory(container: self)
        }
        #endif
    }

    deinit {
        if NSObject.container === self {
            NSObject.container = nil
        }
    }

    public convenience init(assemblies: Assembly..., storyboardable: Bool = false) {
        self.init(assemblies: assemblies, storyboardable: storyboardable)
    }

    func resolveStoryboardable<T>(_ object: Any, as type: T, name: String? = nil) {
        let key = key(type, name: name)
        resolveStoryboardable(object, by: key)
    }

    func resolveStoryboardable(_ object: Any) {
        let key = key(object, name: nil)
        resolveStoryboardable(object, by: key)
    }

    func resolveStoryboardable(_ object: Any, by key: String) {
        let storyboard = storyboards[key]

        if strongRefCycle {
            assert(!storyboard.isNil, "\(key) is not registered")
        }

        storyboard?(object, self)
    }

    private func key<T>(_ type: T, name: String?) -> String {
        let key = String(reflecting: type).normalized
        return name.map { key + "_" + $0 } ?? key
    }

    private func key(_ obj: Any, name: String?) -> String {
        let key = String(reflecting: type(of: obj)).normalized
        return name.map { key + "_" + $0 } ?? key
    }
}

extension Container: Registrator {
    public func registration<T>(for type: T.Type, name: String?) -> Forwarding {
        let key = key(type, name: name)

        guard let storage = storages[key] else {
            fatalError("can't resolve dependency of <\(type)>")
        }

        return Forwarder(container: self, storage: storage)
    }

    public func registerStoryboardable<T>(_ type: T.Type,
                                          _ entity: @escaping (T, Resolver) -> Void) {
        let key = key(type, name: nil)

        if strongRefCycle {
            assert(storyboards[key].isNil, "\(type) is already registered with \(key)")
        }

        storyboards[key] = { c, r in
            if let c = c as? T {
                entity(c, r)
            }
        }
    }

    @discardableResult
    public func register<T>(_ type: T.Type,
                            options: Options = .default,
                            _ entity: @escaping (Resolver, _ arguments: Arguments) -> T) -> Forwarding {
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
}

extension Container: ForwardRegistrator {
    func register<T>(_ type: T.Type, named: String, storage: Storage) {
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

    func register<T>(_ type: T.Type, storage: Storage) {
        let key = key(type, name: nil)

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

extension Container: Resolver {
    public func optionalResolve<T>(_ type: T.Type, with arguments: Arguments) -> T? {
        let key = key(type, name: nil)
        let storage = storages[key]
        return storage?.resolve(with: self, arguments: arguments) as? T
    }

    public func optionalResolve<T>(_ type: T.Type, named: String, with arguments: Arguments) -> T? {
        let key = key(type, name: named)
        let storage = storages[key]
        return storage?.resolve(with: self, arguments: arguments) as? T
    }
}

extension Container /* Storyboardable */ {
    private func makeStoryboardable() {
        if strongRefCycle {
            assert(NSObject.container.isNil, "storyboard handler was registered twice")
        }

        NSObject.container = self
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

private extension Array where Element == Assembly {
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
