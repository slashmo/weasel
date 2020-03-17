@testable import Weasel
import XCTest

final class TCPListenerTests: XCTestCase {
	private let address: SocketAddress = .ipv4(SocketAddress.IPv4(address: sockaddr_in(), host: "localhost"))

	func testItHandlesShutdownSignals() throws {
		let notifier = MockShutdownNotifier()
		let socket = MockSocket()
		let listener = try TCPListener.bound(to: address, shutdownNotifier: notifier, makeSocket: { _ in socket })

		XCTAssertEqual(socket.options[SO_REUSEADDR] as? Int, 1)

		XCTAssertNil(notifier.onShutdown)
		XCTAssertNoThrow(try listener.start())

		notifier.notify()

		XCTAssertFalse(socket.isOpen)
	}

	func testItClosesTheSocketUponBindFailure() throws {
		let socket = MockSocket()
		socket.simulatesBindFailure = true
		XCTAssertThrowsError(try TCPListener.bound(to: address, makeSocket: { _ in socket })) { error in
			XCTAssertFalse(socket.isOpen)
		}
	}

	func testItReportsAcceptedClients() throws {
		let acceptExpectation = expectation(description: "Expected TCPListener to accept a client")

		let clientSocket = MockSocket()
		let serverSocket = MockSocket(clientsToAccept: [clientSocket])

		let listener = try TCPListener.bound(to: address, makeSocket: { _ in serverSocket })
		let delegate = MockTCPListenerDelegate()
		delegate.tcpListenerDidAcceptClient = { client in
			try? client.close()
			XCTAssert(client as? MockSocket === clientSocket)
			acceptExpectation.fulfill()
		}
		listener.delegate = delegate

		XCTAssertNoThrow(try listener.start())

		waitForExpectations(timeout: 0.5)

		XCTAssertFalse(clientSocket.isOpen)
	}
}
