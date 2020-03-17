import Foundation

private let sysClose = close
private let sysSocket = socket
private let sysBind = bind
private let sysSetsockopt: (CInt, CInt, CInt, UnsafeRawPointer?, socklen_t) -> CInt = setsockopt
private let sysGetsockopt: (
	CInt, CInt, CInt, UnsafeMutableRawPointer?, UnsafeMutablePointer<socklen_t>?
) -> CInt = getsockopt

enum Posix {
	#if os(Linux)
		static let SOCK_STREAM = CInt(Glibc.SOCK_STREAM.rawValue)
	#else
		static let SOCK_STREAM = Darwin.SOCK_STREAM
	#endif

	static func close(descriptor: CInt) throws {
		let res = sysClose(descriptor)
		if res == -1 {
			throw CError(errnoCode: errno, reason: "close")
		}
	}

	static func socket(domain: CInt, type: CInt, `protocol`: CInt) throws -> CInt {
		try wrapSysCall {
			sysSocket(domain, type, `protocol`)
		}
	}

	static func setsockopt(
		descriptor: CInt,
		level: CInt,
		optionName: CInt,
		optionValue: UnsafeRawPointer,
		optionLen: socklen_t
	) throws {
		try wrapSysCall {
			sysSetsockopt(descriptor, level, optionName, optionValue, optionLen)
		}
	}

	static func getsockopt(
		descriptor: CInt,
		level: CInt,
		optionName: CInt,
		optionValue: UnsafeMutableRawPointer,
		optionLen: UnsafeMutablePointer<socklen_t>
	) throws {
		try wrapSysCall {
			sysGetsockopt(descriptor, level, optionName, optionValue, optionLen)
		}
	}

	static func bind(descriptor: CInt, ptr: UnsafePointer<sockaddr>, bytes: Int) throws {
		try wrapSysCall {
			sysBind(descriptor, ptr, socklen_t(bytes))
		}
	}
}

@discardableResult
private func wrapSysCall<T: FixedWidthInteger>(
	where function: String = #function,
	_ body: () throws -> T
) throws -> T {
	while true {
		let res = try body()
		if res == -1 {
			let err = errno
			if err == EINTR {
				continue
			}
			throw CError(errnoCode: errno, reason: function)
		}
		return res
	}
}