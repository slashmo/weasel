import Foundation

public struct CError: Error {
	public let errnoCode: CInt
	private let reason: String

	public init(errnoCode: CInt, reason: String) {
		self.errnoCode = errnoCode
		self.reason = reason
	}
}

extension CError: CustomStringConvertible {
	public var description: String {
		localizedDescription
	}

	public var localizedDescription: String {
		guard let cString = strerror(errnoCode) else { return "Unknown error (errno: \(errnoCode))" }
		return "\(reason): \(String(cString: cString)) (errno: \(errnoCode))"
	}
}
