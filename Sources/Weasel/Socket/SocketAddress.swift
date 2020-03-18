import Foundation

public enum SocketAddress {
	case ipv4(IPv4)
	case ipv6(IPv6)

	public init(resolvingHost host: String, port: CInt) throws {
		var info: UnsafeMutablePointer<addrinfo>?
		if getaddrinfo(host, String(port), nil, &info) != 0 {
			throw Error.unknown(host: host, port: port)
		}

		defer {
			if info != nil {
				freeaddrinfo(info)
			}
		}

		guard let addressInfo = info else { throw Error.unsupported }
		switch addressInfo.pointee.ai_family {
		case AF_INET:
			self = addressInfo.pointee.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
				.ipv4(.init(address: ptr.pointee, host: host))
			}
		case AF_INET6:
			self = addressInfo.pointee.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
				.ipv6(.init(address: ptr.pointee, host: host))
			}
		default:
			throw Error.unsupported
		}
	}

	func withSockAddr<R>(_ body: (UnsafePointer<sockaddr>, Int) throws -> R) rethrows -> R {
		switch self {
		case let .ipv4(addr):
			return try addr.address.withSockAddr { try body($0, $1) }
		case let .ipv6(addr):
			return try addr.address.withSockAddr { try body($0, $1) }
		}
	}

	public var protocolFamily: CInt {
		switch self {
		case .ipv4:
			return PF_INET
		case .ipv6:
			return PF_INET6
		}
	}

	public var addressFamily: CInt {
		switch self {
		case .ipv4:
			return AF_INET
		case .ipv6:
			return AF_INET6
		}
	}

	public var port: Int {
		switch self {
		case let .ipv4(addr):
			return Int(in_port_t(bigEndian: addr.address.sin_port))
		case let .ipv6(addr):
			return Int(in_port_t(bigEndian: addr.address.sin6_port))
		}
	}
}

extension SocketAddress: CustomStringConvertible {
	public var description: String {
		let addressString: String
		let host: String?
		let type: String
		switch self {
		case let .ipv4(addr):
			host = addr.host.isEmpty ? nil : addr.host
			type = "IPv4"
			var inAddr = addr.address.sin_addr
			addressString = try! descriptionForAddress(family: addressFamily, bytes: &inAddr, length: INET_ADDRSTRLEN)
		case let .ipv6(addr):
			host = addr.host.isEmpty ? nil : addr.host
			type = "IPv6"
			var inAddr = addr.address.sin6_addr
			addressString = try! descriptionForAddress(family: addressFamily, bytes: &inAddr, length: INET6_ADDRSTRLEN)
		}

		return "[\(type)]\(host.map { "\($0)/\(addressString):" } ?? "\(addressString):")\(port)"
	}
}

public extension SocketAddress {
	struct IPv4 {
		public let address: sockaddr_in
		public let host: String
	}

	struct IPv6 {
		public let address: sockaddr_in6
		public let host: String
	}
}

public extension SocketAddress {
	enum Error: Swift.Error {
		case unknown(host: String, port: CInt)
		case unsupported
	}
}

private func descriptionForAddress(family: CInt, bytes: UnsafeRawPointer, length: CInt) throws -> String {
	var addressBytes = [Int8](repeating: 0, count: Int(length))
	return try addressBytes.withUnsafeMutableBufferPointer { ptr in
		try Posix.inet_ntop(
			addressFamily: family,
			addressBytes: bytes,
			addressDescription: ptr.baseAddress!,
			addressDescriptionLength: socklen_t(length)
		)
		return ptr.baseAddress!.withMemoryRebound(to: UInt8.self, capacity: Int(length)) {
			String(cString: $0)
		}
	}
}

extension sockaddr_in {
	fileprivate func withSockAddr<R>(_ body: (UnsafePointer<sockaddr>, Int) throws -> R) rethrows -> R {
		var addr = self
		return try withUnsafeBytes(of: &addr) { ptr in
			try body(ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self), ptr.count)
		}
	}
}

extension sockaddr_in6 {
	fileprivate func withSockAddr<R>(_ body: (UnsafePointer<sockaddr>, Int) throws -> R) rethrows -> R {
		var addr = self
		return try withUnsafeBytes(of: &addr) { ptr in
			try body(ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self), ptr.count)
		}
	}
}
