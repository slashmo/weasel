import Foundation
import Weasel
import XCTest

final class CErrorTests: XCTestCase {
    func testItProvidesAHelpfulDescription() {
        XCTAssertEqual(
            String(describing: CError(errnoCode: 9, reason: "test")),
            "test: \(String(cString: strerror(9)!)) (errno: 9)"
        )
        XCTAssertEqual(
            String(describing: CError(errnoCode: 48, reason: "test2")),
            "test2: \(String(cString: strerror(48)!)) (errno: 48)"
        )
    }
}
