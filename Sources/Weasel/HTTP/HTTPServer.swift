import Logging

public final class HTTPServer {
	private let logger = Logger(label: "codes.slashmo.weasel.HTTPServer")
	private let tcpListener: TCPListener

	public init(tcpListener: TCPListener) {
		self.tcpListener = tcpListener
		tcpListener.delegate = self
	}

	public func start() throws {
		logger.info("HTTP Server running on port \(tcpListener.address.port)")
		try tcpListener.start()
	}
}

extension HTTPServer: TCPListenerDelegate {
	func tcpListener(_ listener: TCPListener, didAcceptClient client: SocketProtocol) {
		defer {
			try? client.close()
		}

		do {
			let requestString = String(cString: try client.readBytes())

			guard let requestHead = zip(httpRequestLine, httpHeaders).run(requestString).match else {
				var response = HTTPResponse(status: .badRequest)
				response.body = HTTPResponse.Body(response.status.reason)
				logger.error("Abort \(response.status.code): \(response.status.reason)")
				_ = try client.writeString(response.description)
				return
			}

			guard requestHead.0.version == HTTPVersion(major: 1, minor: 1) else {
				var response = HTTPResponse(status: .httpVersionNotSupported)
				response.body = HTTPResponse.Body(response.status.reason)
				logger.error("Abort \(response.status.code): \(response.status.reason)")
				_ = try client.writeString(response.description)
				return
			}

			logger.info("\(requestHead.0.method.rawValue) \(requestHead.0.path)")

			let response = HTTPResponse(status: .ok, body: "Hello, Weasel!")
			_ = try client.writeString(response.description)
		} catch {
			let response = HTTPResponse(status: .internalServerError)
			logger.error(
				"Abort \(response.status.code): \(response.status.reason)",
				metadata: ["error": "\(error.localizedDescription)"]
			)
			_ = try? client.writeString(response.description)
		}
	}
}
