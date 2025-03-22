import Foundation

/// A container that stores arguments for resolving dependencies.
public struct Arguments {
    private let elements: [Any]

    /// Initializes a new container with the specified elements.
    public init(_ elements: [Any]) {
        self.elements = elements
    }

    /// Initializes a new container with the specified elements.
    public init(_ elements: Any...) {
        self.elements = elements
    }

    /// Initializes a new container without elements.
    public init() {
        self.elements = []
    }

    /// Resolves an element of the specified type at the specified index or returns nil.
    public func optionalResolve<T>(_: T.Type = T.self, at index: Int = 0) -> T? {
        return elements.indices.contains(index) ? elements[index] as? T : nil
    }

    /// Resolves an element of the specified type at the specified index.
    public func resolve<T>(_ type: T.Type = T.self, at index: Int = 0) -> T {
        return optionalResolve(type, at: index).unsafelyUnwrapped
    }

    /// Resolves an element of the specified type at the specified index by subscript.
    public subscript<T>(index: Int) -> T {
        return optionalResolve(T.self, at: index).unsafelyUnwrapped
    }

    /// Finds the first element of the specified type or returns nil.
    public func optionalFirst<T>(_: T.Type = T.self) -> T? {
        for element in elements {
            if let resolved = element as? T {
                return resolved
            }
        }
        return nil
    }

    /// Finds the first element of the specified type.
    public func first<T>(_: T.Type = T.self) -> T {
        return optionalFirst().unsafelyUnwrapped
    }

    /// Number of elements in the container.
    public var count: Int {
        return elements.count
    }

    /// A Boolean value indicating whether the container is empty.
    public var isEmpty: Bool {
        return elements.isEmpty
    }
}

#if swift(>=6.0)

extension Arguments: @unchecked Sendable {}

// MARK: - Sequence

extension Arguments: Sequence {
    public func makeIterator() -> some IteratorProtocol {
        return ArgumentsIterator(self)
    }
}

private final class ArgumentsIterator: IteratorProtocol {
    let args: Arguments
    var idx = 0

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
#endif

// MARK: - ExpressibleByArrayLiteral

extension Arguments: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
