import Foundation
import SpryKit
@testable import DIKit

// MARK: - Options + SpryEquatable

extension Options: SpryEquatable {
    static func testMake(accessLevel: AccessLevel = .final,
                         entityKind: EntityKind = .weak) -> Self {
        return .init(accessLevel: accessLevel,
                     entityKind: entityKind)
    }
}

extension Options.EntityKind: SpryEquatable {}

extension Options.AccessLevel: SpryEquatable {}
