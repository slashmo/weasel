import Foundation
import Weasel

final class MockSocket: SocketProtocol {
	private(set) var isOpen = true
	private(set) var boundAddress: SocketAddress?
	private(set) var listenBacklog: CInt?
	private(set) var options = [CInt: Any]()

	var bytesToRead: [UInt8]
	var clientsToAccept: [MockSocket]
	var bytesWritten = [UInt8]()
	var simulatesBindFailure = false
	var simulatesReadFailure = false

	init(bytesToRead: [UInt8] = [], clientsToAccept: [MockSocket] = []) {
		self.bytesToRead = bytesToRead
		self.clientsToAccept = clientsToAccept
	}

	func setOption<T>(level: CInt, name: CInt, value: T) throws {
		options[name] = value
	}

	func bind(to address: SocketAddress) throws {
		guard !simulatesBindFailure else {
			throw CError(errnoCode: EADDRINUSE, reason: #function)
		}
		boundAddress = address
	}

	func listen(backlog: CInt) throws {
		listenBacklog = backlog
	}

	func accept() throws -> SocketProtocol? {
		clientsToAccept.isEmpty ? nil : clientsToAccept.removeFirst()
	}

	func read(pointer: UnsafeMutableRawBufferPointer) throws -> Int {
		guard !simulatesReadFailure else {
			throw CError(errnoCode: SIGPIPE, reason: #function)
		}
		guard !bytesToRead.isEmpty else { return 0 }
		let bytes = bytesToRead[0 ..< min(pointer.count, bytesToRead.endIndex)]
		bytesToRead.removeFirst(min(pointer.count, bytesToRead.endIndex))
		pointer.copyBytes(from: bytes)
		return min(pointer.count, bytes.count)
	}

	func write(pointer: UnsafeRawBufferPointer) throws -> Int {
		bytesWritten = [UInt8](pointer)
		return pointer.count
	}

	func close() throws {
		isOpen = false
	}
}
