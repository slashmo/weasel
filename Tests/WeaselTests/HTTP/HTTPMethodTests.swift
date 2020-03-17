import Weasel
import XCTest

final class HTTPMethodTests: XCTestCase {
	func testItMatchesAllHTTPMethods() {
		for method in HTTPMethod.allCases {
			let (match, rest) = httpMethod.run(method.rawValue)

			XCTAssertEqual(match, method)
			XCTAssertTrue(rest.isEmpty)
		}
	}

	func testItFailsForLowercaseHTTPMethods() {
		for method in HTTPMethod.allCases {
			let lowercasedMethod = method.rawValue.lowercased()
			let (match, rest) = httpMethod.run(lowercasedMethod)

			XCTAssertNil(match)
			XCTAssertEqual(rest, lowercasedMethod[...])
		}
	}

	func testItFailsForNonExistingMethods() {
		let (match, rest) = httpMethod.run("invalid")

		XCTAssertNil(match)
		XCTAssertEqual(rest, "invalid"[...])
	}
}
