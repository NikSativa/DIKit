import Foundation

protocol Abstract: Equatable {
    init(id: Int)
}

final class Instance: Abstract {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    static func ==(lhs: Instance, rhs: Instance) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Value: Abstract {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}
