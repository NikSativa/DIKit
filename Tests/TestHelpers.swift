import Foundation

final class Instance {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}

final class ObservableInstance: ObservableObject {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}

struct Value: Equatable {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}

// MARK: - Instance + Equatable

extension Instance: Equatable {
    static func ==(lhs: Instance, rhs: Instance) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - ObservableInstance + Equatable

extension ObservableInstance: Equatable {
    static func ==(lhs: ObservableInstance, rhs: ObservableInstance) -> Bool {
        return lhs.id == rhs.id
    }
}
