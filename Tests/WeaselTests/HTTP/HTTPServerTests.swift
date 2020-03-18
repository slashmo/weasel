@testable import Weasel
import XCTest

final class HTTPServerTests: XCTestCase {
	private let address: SocketAddress = .ipv4(SocketAddress.IPv4(address: sockaddr_in(), host: "localhost"))

	func testItClosesTheClientAfterSuccessfullyReading() throws {
		let requestMessage = """
		GET / HTTP/1.1\r
		Content-Type: application/json\r
		\r
		\r
		"""

		let clientSocket = MockSocket(bytesToRead: [UInt8](requestMessage.utf8))
		let serverSocket = MockSocket(clientsToAccept: [clientSocket])

		let httpServer = try HTTPServer(tcpListener: .bound(to: address, makeSocket: { _ in serverSocket }))
		XCTAssertNoThrow(try httpServer.start())

		XCTAssertFalse(clientSocket.isOpen)
		XCTAssert(String(cString: clientSocket.bytesWritten).starts(with: "HTTP/1.1 200 OK\r\n"))
	}

	func testItRespondsWith400ToInvalidReqests() throws {
		let requestMessage = "clearly not HTTP"
		let clientSocket = MockSocket(bytesToRead: [UInt8](requestMessage.utf8))
		let serverSocket = MockSocket(clientsToAccept: [clientSocket])

		let httpServer = try HTTPServer(tcpListener: .bound(to: address, makeSocket: { _ in serverSocket }))
		XCTAssertNoThrow(try httpServer.start())

		XCTAssertFalse(clientSocket.isOpen)
		XCTAssert(String(cString: clientSocket.bytesWritten).starts(with: "HTTP/1.1 400 Bad Request\r\n"))
	}

	func testItRespondsWith500IfReadingFromClientFails() throws {
		let clientSocket = MockSocket()
		clientSocket.simulatesReadFailure = true
		let serverSocket = MockSocket(clientsToAccept: [clientSocket])

		let httpServer = try HTTPServer(tcpListener: .bound(to: address, makeSocket: { _ in serverSocket }))
		XCTAssertNoThrow(try httpServer.start())

		XCTAssertFalse(clientSocket.isOpen)
		XCTAssert(String(cString: clientSocket.bytesWritten).starts(with: "HTTP/1.1 500 Internal Server Error\r\n"))
	}

	func testItRespondsWith505IfRequestUsesUnsupportedHTTPVersion() throws {
		let requestMessage = """
		GET / HTTP/2.0\r
		\r
		\r
		"""
		let clientSocket = MockSocket(bytesToRead: [UInt8](requestMessage.utf8))
		let serverSocket = MockSocket(clientsToAccept: [clientSocket])

		let httpServer = try HTTPServer(tcpListener: .bound(to: address, makeSocket: { _ in serverSocket }))
		XCTAssertNoThrow(try httpServer.start())

		XCTAssertFalse(clientSocket.isOpen)
		XCTAssert(String(cString: clientSocket.bytesWritten).starts(with: "HTTP/1.1 505 HTTP Version Not Supported\r\n"))
	}
}
