import Foundation

public struct Arguments {
    private let elements: [Any]

    public init(_ elements: [Any]) {
        self.elements = elements
    }

    public init(_ elements: Any...) {
        self.elements = elements
    }

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
}

// MARK: - ExpressibleByArrayLiteral

extension Arguments: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
