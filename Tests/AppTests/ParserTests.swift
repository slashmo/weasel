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
		let intToBool = int.flatMap { $0 == 0 ? always(false) : always(true) }

		let falseResult = intToBool.run("0")
		XCTAssertEqual(falseResult.match, false)
		XCTAssertTrue(falseResult.rest.isEmpty)

		let trueResult = intToBool.run("1")
		XCTAssertEqual(trueResult.match, true)
		XCTAssertTrue(trueResult.rest.isEmpty)
	}

	func testFlatMapUndosTheOuterMutationIfTheInnerParserFails() {
		let result = int
			.flatMap { _ in Parser<Never>.never }
			.run("1a")

		XCTAssertNil(result.match)
		XCTAssertEqual(result.rest, "1a")
	}

	func testOneOfReturnsTheFirstMatch() {
		let result = oneOf([literal("a"), literal("b")]).run("b")

		XCTAssertNotNil(result.match)
		XCTAssertTrue(result.rest.isEmpty)
	}

	func testOneOfFailsIfNoneMatches() {
		let result = oneOf([literal("a"), literal("b")]).run("c")

		XCTAssertNil(result.match)
		XCTAssertEqual(result.rest, "c")
	}

	func testPrefixReturnsAllCharactersMatchingTheClosure() {
		let (match, rest) = prefix(while: { !$0.isWhitespace }).run("Hello, Weasel!")

		XCTAssertEqual(match, "Hello,")
		XCTAssertEqual(rest, " Weasel!")
	}
}
