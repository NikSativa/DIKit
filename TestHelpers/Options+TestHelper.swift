import Foundation
import NSpry

@testable import NInject

extension Options: SpryEquatable {
    static func testMake(accessLevel: AccessLevel = .final,
                         entityKind: EntityKind = .weak) -> Self {
        return .init(accessLevel: accessLevel,
                     entityKind: entityKind)
    }
}

extension Options.EntityKind: SpryEquatable {}

extension Options.AccessLevel: SpryEquatable {}
