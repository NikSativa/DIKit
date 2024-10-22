import Foundation

/// An assembly that assembles dependencies for future container
@MainActor
public protocol Assembly {
    /// Unique identifier of the assembly that will be used to used to remove duplicates from the Container
    /// - Warning:  override it on your own risk
    var id: String { get }

    /// List of assemblies that this assembly depends on
    var dependencies: [Assembly] { get }

    /// Assembles dependencies for the specified registrator
    func assemble(with registrator: Registrator)
}

public extension Assembly {
    var id: String {
        return String(reflecting: type(of: self))
    }

    var dependencies: [Assembly] {
        return []
    }
}
