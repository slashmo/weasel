import Foundation

public struct HTTPResponse {
	public let version: HTTPVersion
	public internal(set) var status: Status
	public var headers: HTTPHeaders
	public var body: Body {
		didSet {
			headers.upsert(name: "Content-Length", value: body.count.description)
		}
	}

	public init(
		version: HTTPVersion = HTTPVersion(major: 1, minor: 1),
		status: Status,
		headers: HTTPHeaders = [:],
		body: Body = Body()
	) {
		self.version = version
		self.status = status
		self.headers = headers
		self.body = body
	}
}

extension HTTPResponse: CustomStringConvertible {
	public var description: String {
		"""
		HTTP/\(version.major).\(version.minor) \(status.code) \(status.reason)\r
		\(headers.description)
		\(body.description)
		"""
	}
}

public extension HTTPResponse {
	enum Status {
		case custom(code: UInt, reason: String)

		case `continue`
		case switchingProtocols
		case processing
		case earlyHints

		case ok
		case created
		case accepted
		case nonAuthoritativeInformation
		case noContent
		case resetContent
		case partialContent
		case multiStatus
		case alreadyReported
		case imUsed

		case multipleChoices
		case movedPermanently
		case found
		case seeOther
		case notModified
		case useProxy
		case temporaryRedirect
		case permanentRedirect

		case badRequest
		case unauthorized
		case paymentRequired
		case forbidden
		case notFound
		case methodNotAllowed
		case notAcceptable
		case proxyAuthenticationRequired
		case requestTimeout
		case conflict
		case gone
		case lengthRequired
		case preconditionFailed
		case payloadTooLarge
		case uriTooLong
		case unsupportedMediaType
		case rangeNotSatisfiable
		case expectationFailed
		case misdirectedRequest
		case unprocessableEntity
		case locked
		case failedDependency
		case tooEarly
		case upgradeRequired
		case preconditionRequired
		case tooManyRequests
		case requestHeaderFieldsTooLarge
		case unavailableForLegalReasons

		case internalServerError
		case notImplemented
		case badGateway
		case serviceUnavailable
		case gatewayTimeout
		case httpVersionNotSupported
		case variantAlsoNegotiates
		case insufficientStorage
		case loopDetected
		case notExtended
		case networkAuthenticationRequired

		var code: UInt {
			metadata.code
		}

		var reason: String {
			metadata.reason
		}

		private var metadata: (code: UInt, reason: String) {
			switch self {
			case .continue:
				return (100, "Continue")
			case .switchingProtocols:
				return (101, "Switching Protocols")
			case .processing:
				return (102, "Processing")
			case .earlyHints:
				return (103, "Early Hints")
			case .ok:
				return (200, "OK")
			case .created:
				return (201, "Created")
			case .accepted:
				return (202, "Accepted")
			case .nonAuthoritativeInformation:
				return (203, "Non-Authoritative Information")
			case .noContent:
				return (204, "No Content")
			case .resetContent:
				return (205, "Reset Content")
			case .partialContent:
				return (206, "Partial Content")
			case .multiStatus:
				return (207, "Multi-Status")
			case .alreadyReported:
				return (208, "Already Reported")
			case .imUsed:
				return (226, "IM Used")
			case .multipleChoices:
				return (300, "Multiple Choices")
			case .movedPermanently:
				return (301, "Moved Permanently")
			case .found:
				return (302, "Found")
			case .seeOther:
				return (303, "See Other")
			case .notModified:
				return (304, "Not Modified")
			case .useProxy:
				return (305, "Use Proxy")
			case .temporaryRedirect:
				return (307, "Temporary Redirect")
			case .permanentRedirect:
				return (308, "Permanent Redirect")
			case .badRequest:
				return (400, "Bad Request")
			case .unauthorized:
				return (401, "Unauthorized")
			case .paymentRequired:
				return (402, "Payment Required")
			case .forbidden:
				return (403, "Forbidden")
			case .notFound:
				return (404, "Not Found")
			case .methodNotAllowed:
				return (405, "Method Not Allowed")
			case .notAcceptable:
				return (406, "Not Acceptable")
			case .proxyAuthenticationRequired:
				return (407, "Proxy Authentication Required")
			case .requestTimeout:
				return (408, "Request Timeout")
			case .conflict:
				return (409, "Conflict")
			case .gone:
				return (410, "Gone")
			case .lengthRequired:
				return (411, "Length Required")
			case .preconditionFailed:
				return (412, "Precondition Failed")
			case .payloadTooLarge:
				return (413, "Payload Too Large")
			case .uriTooLong:
				return (414, "URI Too Long")
			case .unsupportedMediaType:
				return (415, "Unsupported Media Type")
			case .rangeNotSatisfiable:
				return (416, "Range Not Satisfiable")
			case .expectationFailed:
				return (417, "Expectation Failed")
			case .misdirectedRequest:
				return (421, "Misdirected Request")
			case .unprocessableEntity:
				return (422, "Unprocessable Entity")
			case .locked:
				return (423, "Locked")
			case .failedDependency:
				return (424, "Failed Dependency")
			case .tooEarly:
				return (425, "Too Early")
			case .upgradeRequired:
				return (426, "Upgrade Required")
			case .preconditionRequired:
				return (428, "Precondition Required")
			case .tooManyRequests:
				return (429, "Too Many Requests")
			case .requestHeaderFieldsTooLarge:
				return (431, "Request Header Fields Too Large")
			case .unavailableForLegalReasons:
				return (451, "Unavailable For Legal Reasons")
			case .internalServerError:
				return (500, "Internal Server Error")
			case .notImplemented:
				return (501, "Not Implemented")
			case .badGateway:
				return (502, "Bad Gateway")
			case .serviceUnavailable:
				return (503, "Service Unavailable")
			case .gatewayTimeout:
				return (504, "Gateway Timeout")
			case .httpVersionNotSupported:
				return (505, "HTTP Version Not Supported")
			case .variantAlsoNegotiates:
				return (506, "Variant Also Negotiates")
			case .insufficientStorage:
				return (507, "Insufficient Storage")
			case .loopDetected:
				return (508, "Loop Detected")
			case .notExtended:
				return (510, "Not Extended")
			case .networkAuthenticationRequired:
				return (511, "Network Authentication Required")
			case let .custom(code, reason):
				return (code, reason)
			}
		}
	}
}

public extension HTTPResponse {
	struct Body {
		private let storage: Storage

		public init(_ string: String) {
			self.storage = .string(string)
		}

		public init(_ data: Data) {
			self.storage = .data(data)
		}

		public init() {
			self.storage = .none
		}

		public var count: Int {
			switch storage {
			case .none:
				return 0
			case let .string(string):
				return string.utf8.count
			case let .data(data):
				return data.count
			}
		}
	}
}

extension HTTPResponse.Body {
	fileprivate enum Storage {
		case none
		case string(String)
		case data(Data)
	}
}

extension HTTPResponse.Body: CustomStringConvertible {
	public var description: String {
		switch storage {
		case .none:
			return "<no body"
		case let .string(string):
			return string
		case let .data(data):
			return String(data: data, encoding: .ascii) ?? "n/a"
		}
	}
}

extension HTTPResponse.Body: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = HTTPResponse.Body(value)
	}
}
