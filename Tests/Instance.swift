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
