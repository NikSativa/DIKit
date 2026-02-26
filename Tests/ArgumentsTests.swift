import DIKit
import Foundation
import XCTest

final class ArgumentsTests: XCTestCase {
    func test_sequence_iterates_all_elements_in_order() {
        let args = Arguments(1, "two", 3.0)
        let values = Array(args)

        XCTAssertEqual(values.count, 3)
        XCTAssertEqual(values[0] as? Int, 1)
        XCTAssertEqual(values[1] as? String, "two")
        XCTAssertEqual(values[2] as? Double, 3.0)
    }
}
