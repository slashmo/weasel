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
				logger.error("Abort 400: Bad Request")
				_ = try client.writeString("HTTP/1.1 400 Bad Request\r\n")
				return
			}

			guard requestHead.0.version == HTTPVersion(major: 1, minor: 1) else {
				logger.error("Abort 505: HTTP Version Not Supported")
				_ = try client.writeString("HTTP/1.1 505 HTTP Version Not Supported\r\n")
				return
			}

			logger.info("\(requestHead.0.method.rawValue) \(requestHead.0.path)")

			let response = "HTTP/1.1 200 OK\r\n"
			_ = try client.writeString(response)
		} catch {
			logger.error("Abort 500: Internal Server Error", metadata: ["error": "\(error.localizedDescription)"])
			_ = try? client.writeString("HTTP/1.1 500 Internal Server Error\r\n")
		}
	}
}
