import App
import Foundation
import XCTest

final class CErrorTests: XCTestCase {
	func testItProvidesAHelpfulDescription() {
		XCTAssertEqual(
			CError(errnoCode: 9, reason: "test").description,
			"test: \(String(cString: strerror(9)!)) (errno: 9)"
		)
		XCTAssertEqual(
			CError(errnoCode: 48, reason: "test2").description,
			"test2: \(String(cString: strerror(48)!)) (errno: 48)"
		)
	}
}
