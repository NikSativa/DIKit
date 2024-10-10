import Foundation

@MainActor
public struct Arguments {
    private let elements: [Any]

    @MainActor
    public init(_ elements: [Any]) {
        self.elements = elements
    }

    @MainActor
    public init(_ elements: Any...) {
        self.elements = elements
    }

    @MainActor
    public init() {
        self.elements = []
    }

    public func optionalResolve<T>(_: T.Type = T.self, at index: Int = 0) -> T? {
        return elements.indices.contains(index) ? elements[index] as? T : nil
    }

    public func resolve<T>(_ type: T.Type = T.self, at index: Int = 0) -> T {
        return optionalResolve(type, at: index).unsafelyUnwrapped
    }

    public subscript<T>(index: Int) -> T {
        return optionalResolve(T.self, at: index).unsafelyUnwrapped
    }

    public func optionalFirst<T>(_: T.Type = T.self) -> T? {
        for element in elements {
            if let resolved = element as? T {
                return resolved
            }
        }
        return nil
    }

    public func first<T>(_: T.Type = T.self) -> T {
        return optionalFirst().unsafelyUnwrapped
    }

    public var count: Int {
        return elements.count
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }
}

#if swift(>=6.0)

// MARK: - Sequence

extension Arguments: @preconcurrency Sequence {
    public func makeIterator() -> some IteratorProtocol {
        return ArgumentsIterator(self)
    }
}

@MainActor
private final class ArgumentsIterator: @preconcurrency IteratorProtocol {
    let args: Arguments
    var idx = 0

    @MainActor
    init(_ args: Arguments) {
        self.args = args
    }

    func next() -> Int? {
        guard idx < 0 || idx >= args.count else {
            return nil
        }

        defer {
            idx += 1
        }
        return args[idx]
    }
}

// MARK: - Arguments + ExpressibleByArrayLiteral

@MainActor
extension Arguments: @preconcurrency ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
#else

// MARK: - Arguments + ExpressibleByArrayLiteral

extension Arguments: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
#endif
