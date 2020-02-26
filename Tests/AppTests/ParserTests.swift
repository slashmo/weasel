@testable import App
import XCTest

final class ParserTests: XCTestCase {
	func testLiteralEatsOfTheString() {
		let (match, rest): (Void?, Substring) = literal("a").run("abc")

		XCTAssertNotNil(match)
		XCTAssertEqual(rest, "bc")
	}

	func testLiteralOnlyEatsMatch() {
		let (match, rest): (Void?, Substring) = literal("b").run("abc")

		XCTAssertNil(match)
		XCTAssertEqual(rest, "abc")
	}

	func testMapTransformsTheParsedResult() {
		let (match, rest) = int.map(String.init).run("1")

		XCTAssertEqual(match, "1")
		XCTAssertTrue(rest.isEmpty)
	}

	func testFlatMapForwardsTheParsedResultToTheGivenParser() {
		var falseStr = "0"[...]
		var trueStr = "1"[...]

		let intToBool = int.flatMap { $0 == 0 ? always(false) : always(true) }

		XCTAssertEqual(intToBool.run(&falseStr), false)
		XCTAssertEqual(intToBool.run(&trueStr), true)

		XCTAssertTrue(falseStr.isEmpty)
		XCTAssertTrue(trueStr.isEmpty)
	}

	func testFlatMapUndosTheOuterMutationIfTheInnerParserFails() {
		var str = "1a"[...]
		let result: Void? = int
			.flatMap { _ in .never }
			.run(&str)

		XCTAssertNil(result)
		XCTAssertEqual(str, "1a")
	}
}
