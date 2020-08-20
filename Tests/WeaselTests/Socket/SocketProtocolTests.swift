@testable import Weasel
import XCTest

final class SocketProtocolTests: XCTestCase {
    func testReadsInChunks() throws {
        let count = Int.random(in: 1000 ... 2000)
        let bytesToRead = (0 ..< count).reduce(into: [UInt8]()) { bytes, _ in bytes.append(.random(in: .min ... .max)) }
        let socket = MockSocket(bytesToRead: bytesToRead)

        XCTAssertEqual(try socket.readBytes(inChunksOf: 200), bytesToRead)
    }

    func testWritesStrings() throws {
        let string = "Hello, Test ✌️"
        let socket = MockSocket()

        XCTAssertEqual(try socket.writeString(string), string.utf8.count)
        XCTAssertEqual(socket.bytesWritten, [UInt8](string.utf8))
    }
}
