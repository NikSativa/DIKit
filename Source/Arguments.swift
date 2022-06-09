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

    public func optionalResolve<T>(_: T.Type, at index: Int) -> T? {
        return elements.indices.contains(index) ? elements[index] as? T : nil
    }

    public func optionalResolve<T>(at index: Int) -> T? {
        optionalResolve(T.self, at: index)
    }

    public func resolve<T>(_: T.Type, at index: Int) -> T {
        // swiftlint:disable:next force_cast
        elements[index] as! T
    }

    public func resolve<T>(at index: Int) -> T {
        resolve(T.self, at: index)
    }

    public subscript<T>(index: Int) -> T {
        // swiftlint:disable:next force_cast
        elements[index] as! T
    }

    public func optionalFirst<T>(_: T.Type = T.self) -> T? {
        elements.lazy.compactMap { $0 as? T }.first
    }

    public func first<T>(_ type: T.Type = T.self) -> T {
        optionalFirst(type)!
    }
}
