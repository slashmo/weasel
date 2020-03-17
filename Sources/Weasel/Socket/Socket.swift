import Foundation

public final class Socket: SocketProtocol {
	private var descriptor: CInt

	init(descriptor: CInt) {
		self.descriptor = descriptor
	}

	public convenience init(protocolFamily: CInt) throws {
		let descriptor = try Posix.socket(domain: protocolFamily, type: Posix.SOCK_STREAM, protocol: 0)
		self.init(descriptor: descriptor)
	}

	deinit {
		assert(!isOpen, "Socket was not closed!")
	}

	public func setOption<T>(level: CInt, name: CInt, value: T) throws {
		try withUnsafeDescriptor { d in
			var val = value
			try Posix.setsockopt(
				descriptor: d,
				level: level,
				optionName: name,
				optionValue: &val,
				optionLen: socklen_t(MemoryLayout.size(ofValue: val))
			)
		}
	}

	public func bind(to address: SocketAddress) throws {
		try withUnsafeDescriptor { d in
			try address.withSockAddr { try Posix.bind(descriptor: descriptor, ptr: $0, bytes: $1) }
		}
	}

	public func listen(backlog: CInt) throws {
		try withUnsafeDescriptor { d in
			try Posix.listen(descriptor: d, backlog: backlog)
		}
	}

	public func accept() throws -> SocketProtocol? {
		try withUnsafeDescriptor {
			try Posix.accept(descriptor: $0, addr: nil, len: nil).map(Socket.init)
		}
	}

	public func read(pointer: UnsafeMutableRawBufferPointer) throws -> Int {
		try withUnsafeDescriptor { d in
			try Posix.read(descriptor: d, pointer: pointer.baseAddress!, size: pointer.count)
		}
	}

	public func write(pointer: UnsafeRawBufferPointer) throws -> Int {
		try withUnsafeDescriptor { d in
			try Posix.write(descriptor: d, pointer: pointer.baseAddress!, size: pointer.count)
		}
	}

	public func close() throws {
		try withUnsafeDescriptor { d in
			descriptor = -1
			try Posix.close(descriptor: d)
		}
	}

	public var isOpen: Bool {
		descriptor >= 0
	}

	private func withUnsafeDescriptor<T>(_ body: (CInt) throws -> T) throws -> T {
		guard isOpen else {
			throw CError(errnoCode: EBADF, reason: "socket descriptor already closed")
		}
		return try body(descriptor)
	}
}

extension Socket: CustomStringConvertible {
	public var description: String {
		"Socket { fd=\(descriptor) }"
	}
}
