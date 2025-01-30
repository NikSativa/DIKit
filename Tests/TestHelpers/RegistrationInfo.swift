import DIKit
import Foundation

enum RegistrationInfo {
    case register(Any.Type, Options)
    case registerStoryboardable(Any.Type)
    case registerViewController(Any.Type)
    case forwarding(to: Any.Type, accessLevel: Options.AccessLevel)
    case forwardingName(to: Any.Type, name: String?, accessLevel: Options.AccessLevel)
}
