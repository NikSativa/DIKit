import Foundation
import SpryKit
@testable import DIKit

enum RegistrationInfo: Equatable, SpryEquatable {
    case register(Any.Type, Options)
    case registerStoryboardable(Any.Type)
    case registerViewController(Any.Type)
    case forwarding(to: Any.Type, accessLevel: Options.AccessLevel)
    case forwardingName(to: Any.Type, name: String?, accessLevel: Options.AccessLevel)

    static func ==(lhs: RegistrationInfo, rhs: RegistrationInfo) -> Bool {
        switch (lhs, rhs) {
        case (.register(let ta, let ka), .register(let tb, let kb)):
            return ta == tb && ka == kb
        case (.registerStoryboardable(let ta), .registerStoryboardable(let tb)):
            return ta == tb
        case (.registerViewController(let ta), .registerViewController(let tb)):
            return ta == tb
        case (.forwarding(let ta, let accessLevelA), .forwarding(let tb, let accessLevelB)):
            return ta == tb && accessLevelA == accessLevelB
        case (.forwardingName(let ta, let nameA, let accessLevelA), .forwardingName(let tb, let nameB, let accessLevelB)):
            return ta == tb && nameA == nameB && accessLevelA == accessLevelB
        case (.forwarding, _),
             (.forwardingName, _),
             (.register, _),
             (.registerStoryboardable, _),
             (.registerViewController, _):
            return false
        }
    }

    var type: Any.Type {
        switch self {
        case .forwarding(to: let t, accessLevel: _),
             .forwardingName(to: let t, name: _, accessLevel: _),
             .register(let t, _),
             .registerStoryboardable(let t),
             .registerViewController(let t):
            return t
        }
    }
}
