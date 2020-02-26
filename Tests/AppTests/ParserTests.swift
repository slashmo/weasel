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

	func testZipChainsMultipleParsers() {
		let (match, rest) = zip(int, literal("a")).run("1a")

		XCTAssertEqual(match?.0, 1)
		XCTAssertTrue(rest.isEmpty)
	}

	func testZipFailsTheWholeChainWhenTheFirstParserFails() {
		let (match, rest) = zip(int, literal("a")).run("aa")

		XCTAssertNil(match)
		XCTAssertEqual(rest, "aa")
	}

	func testZipFailsTheWholeChainWhenAChainedParserFails() {
		let (match, rest) = zip(int, literal("a")).run("1b")

		XCTAssertNil(match)
		XCTAssertEqual(rest, "1b")
	}

	func testZipThreeParsers() {
		let (match, rest) = zip(int, literal(","), int).run("1,2")

		XCTAssertEqual(match?.0, 1)
		XCTAssertEqual(match?.2, 2)
		XCTAssertTrue(rest.isEmpty)
	}

	func testZipFourParsers() {
		let (match, rest) = zip(int, literal(","), int, literal("|")).run("1,2|")

		XCTAssertEqual(match?.0, 1)
		XCTAssertEqual(match?.2, 2)
		XCTAssertTrue(rest.isEmpty)
	}

	func testZipFiveParsers() {
		let (match, rest) = zip(int, literal(","), int, literal("|"), int).run("1,2|1")

		XCTAssertEqual(match?.0, 1)
		XCTAssertEqual(match?.2, 2)
		XCTAssertEqual(match?.4, 1)
		XCTAssertTrue(rest.isEmpty)
	}

	func testZipSixParsers() {
		let (match, rest) = zip(int, literal(","), int, literal("|"), int, literal("A")).run("1,2|1A")

		XCTAssertEqual(match?.0, 1)
		XCTAssertEqual(match?.2, 2)
		XCTAssertEqual(match?.4, 1)
		XCTAssertTrue(rest.isEmpty)
	}

	func testZeroOrMoreParsesTwoLiteralsSeparatedByAComma() {
		let result = zeroOrMore(literal("a"), separatedBy: literal(",")).run("a,ab")

		XCTAssertEqual(result.match?.count, 2)
		XCTAssertEqual(result.rest, "b")
	}

	func testZeroOrMoreIsSuccessfulWithZeroMatches() {
		let result = zeroOrMore(literal("a"), separatedBy: literal(";")).run("b;b")

		XCTAssertEqual(result.match?.isEmpty, true)
		XCTAssertEqual(result.rest, "b;b")
	}

	func testZeroOrMoreSpacesRemovesSpaces() {
		let result = zeroOrMoreSpaces.run("   ")

		XCTAssertNotNil(result.match)
		XCTAssertTrue(result.rest.isEmpty)
	}

	func testZeroOrMoreSpacesIsSuccessfulWithZeroMatches() {
		let result = zeroOrMoreSpaces.run("abc")

		XCTAssertNotNil(result.match)
		XCTAssertEqual(result.rest, "abc")
	}
}
