@testable import Weasel
import XCTest

final class HTTPHeaderTest: XCTestCase {
    func testItMatchesAValidHTTPHeader() {
        let key = "Accept"
        let value = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
        let header = "\(key): \(value)"
        let (match, rest) = httpHeader.run(header)

        XCTAssertEqual(match?.0, key)
        XCTAssertEqual(match?.1, value)
        XCTAssertTrue(rest.isEmpty)
    }

    func testItTrimsTrailingWhitespaceFromTheValue() {
        let key = "Accept-Language"
        let value = "en-US,en;q=0.5"
        let header = "\(key): \(value)              "
        let (match, rest) = httpHeader.run(header)

        XCTAssertEqual(match?.0, key)
        XCTAssertEqual(match?.1, value)
        XCTAssertTrue(rest.isEmpty)
    }

    func testItTrimsLeadingWhitespaceFromTheValue() {
        let key = "Accept-Language"
        let value = "en-US,en;q=0.5"
        let header = "\(key):              \(value)"
        let (match, rest) = httpHeader.run(header)

        XCTAssertEqual(match?.0, key)
        XCTAssertEqual(match?.1, value)
        XCTAssertTrue(rest.isEmpty)
    }

    func testMultipleHeadersAreSeparatedByCRLF() {
        let headers = """
        Host: localhost\r
        DNT: 1 \r
        Connection: keep-alive
        """
        let (match, rest) = httpHeaders.run(headers)

        XCTAssertEqual(match, HTTPHeaders([
            ("Host", "localhost"),
            ("DNT", "1"),
            ("Connection", "keep-alive")
        ]))

        XCTAssertEqual(match?["Host"], ["localhost"])
        XCTAssertEqual(match?["DNT"], ["1"])
        XCTAssertEqual(match?["Connection"], ["keep-alive"])
        XCTAssertTrue(rest.isEmpty)
    }

    func testHeaderKeysMayBeDuplicated() {
        let headers = """
        Cache-Control: no-cache\r
        Accept-Encoding: gzip, deflate\r
        Cache-Control: no-store
        """
        let (match, rest) = httpHeaders.run(headers)

        XCTAssertEqual(match, HTTPHeaders([
            ("Cache-Control", "no-cache"),
            ("Accept-Encoding", "gzip, deflate"),
            ("Cache-Control", "no-store")
        ]))
        XCTAssertEqual(match?["Cache-Control"], ["no-cache", "no-store"])
        XCTAssertTrue(rest.isEmpty)
    }

    func testEquatableConformance() {
        XCTAssertEqual(
            HTTPHeaders([("Authorization", "Bearer xyz")]),
            HTTPHeaders([("Authorization", "Bearer xyz")])
        )
        XCTAssertEqual(
            HTTPHeaders([("Host", "localhost"), ("Connection", "keep-alive")]),
            HTTPHeaders([("Host", "localhost"), ("Connection", "keep-alive")])
        )

        XCTAssertNotEqual(HTTPHeaders(), HTTPHeaders([("Authorization", "Bearer xyz")]))
        XCTAssertNotEqual(
            HTTPHeaders([("Authorization", "Bearer xyz")]),
            HTTPHeaders([("Cache-Control", "keep-alive")])
        )
        XCTAssertNotEqual(
            HTTPHeaders([("Authorization", "Bearer abc")]),
            HTTPHeaders([("Authorization", "Bearer xyz")])
        )
    }

    func testRemoveRemovesAllAccurancesOfAHeaderName() {
        var headers = HTTPHeaders([
            ("Authorization", "Bearer xyz"),
            ("Cache-Control", "no-cache"),
            ("Cache-Control", "no-store")
        ])

        headers.remove(name: "Cache-Control")

        XCTAssertEqual(headers, ["Authorization": "Bearer xyz"])
    }
}
