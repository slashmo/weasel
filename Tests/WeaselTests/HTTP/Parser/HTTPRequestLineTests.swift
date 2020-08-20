import Weasel
import XCTest

final class HTTPRequestLineTests: XCTestCase {
    func testItParsesTheRequestLine() {
        let path = "/users/1"
        let (match, rest) = httpRequestLine.run("GET \(path) HTTP/1.1\r\n")

        XCTAssertEqual(match?.method, .get)
        XCTAssertEqual(match?.path, path)
        XCTAssertEqual(match?.version.major, 1)
        XCTAssertEqual(match?.version.minor, 1)
        XCTAssertTrue(rest.isEmpty)
    }
}
