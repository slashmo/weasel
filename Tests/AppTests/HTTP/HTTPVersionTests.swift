import App
import XCTest

final class HTTPVersionTests: XCTestCase {
	func testItMatchesAValidHTTPVersion() {
		let (onePointOne, rest1) = httpVersion.run("HTTP/1.1")

		XCTAssertEqual(onePointOne?.major, 1)
		XCTAssertEqual(onePointOne?.minor, 1)
		XCTAssertTrue(rest1.isEmpty)
	}
}
