import Foundation

/// Cross-platform wrapper around system calls.
enum OS {
	#if os(Linux)
	static let bind = Glibc.bind
	static let listen = Glibc.listen
	static let accept = Glibc.accept
	static let close = Glibc.close
	static let write = Glibc.write
	#else
	static let bind = Darwin.bind
	static let listen = Darwin.listen
	static let accept = Darwin.accept
	static let close = Darwin.close
	static let write = Darwin.write
	#endif
}
