import Foundation

final class Instance: Equatable {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    static func ==(lhs: Instance, rhs: Instance) -> Bool {
        return lhs.id == rhs.id
    }
}

final class ObservableInstance: ObservableObject, Equatable {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    static func ==(lhs: ObservableInstance, rhs: ObservableInstance) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Value: Equatable {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}
