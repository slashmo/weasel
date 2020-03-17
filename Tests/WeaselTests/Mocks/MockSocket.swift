import Foundation
import Weasel

final class MockSocket: SocketProtocol {
	private(set) var isOpen = true
	private(set) var boundAddress: SocketAddress?
	private(set) var listenBacklog: CInt?

	var bytesToRead: [UInt8]
	var bytesWritten = [UInt8]()

	init(bytesToRead: [UInt8] = []) {
		self.bytesToRead = bytesToRead
	}

	func close() throws {
		isOpen = false
	}

	func bind(to address: SocketAddress) throws {
		boundAddress = address
	}

	func listen(backlog: CInt) throws {
		listenBacklog = backlog
	}

	func read(pointer: UnsafeMutableRawBufferPointer) throws -> Int {
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
}
