import Foundation

@MainActor
final class Instance {
    let id: Int

    @MainActor
    init(id: Int) {
        self.id = id
    }
}

@MainActor
final class ObservableInstance: ObservableObject {
    let id: Int

    @MainActor
    init(id: Int) {
        self.id = id
    }
}

@MainActor
struct Value: Equatable {
    let id: Int

    @MainActor
    init(id: Int) {
        self.id = id
    }
}

#if swift(>=6.0)
extension Instance: @preconcurrency Equatable {
    static func ==(lhs: Instance, rhs: Instance) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ObservableInstance: @preconcurrency Equatable {
    static func ==(lhs: ObservableInstance, rhs: ObservableInstance) -> Bool {
        return lhs.id == rhs.id
    }
}
#else
extension Instance: Equatable {
    static func ==(lhs: Instance, rhs: Instance) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ObservableInstance: Equatable {
    static func ==(lhs: ObservableInstance, rhs: ObservableInstance) -> Bool {
        return lhs.id == rhs.id
    }
}
#endif
