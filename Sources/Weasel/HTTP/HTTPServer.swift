import Logging

public final class HTTPServer {
    private let logger = Logger(label: "codes.slashmo.weasel.HTTPServer")
    private let tcpListener: TCPListener
    private let responder: HTTPResponder

    public init(tcpListener: TCPListener, responder: HTTPResponder = DefaultHTTPResponder()) {
        self.tcpListener = tcpListener
        self.responder = responder
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
                try client.writeString(String(describing: response))
                return
            }

            guard requestHead.0.version == HTTPVersion(major: 1, minor: 1) else {
                var response = HTTPResponse(status: .httpVersionNotSupported)
                response.body = HTTPResponse.Body(response.status.reason)
                logger.error("Abort \(response.status.code): \(response.status.reason)")
                try client.writeString(String(describing: response))
                return
            }

            responder.respond(to: HTTPRequest()).observe { result in
                if let response = try? result.get() {
                    _ = try? client.writeString(String(describing: response))
                }
            }
        } catch {
            let response = HTTPResponse(status: .internalServerError)
            logger.error(
                "Abort \(response.status.code): \(response.status.reason)",
                metadata: ["error": "\(error.localizedDescription)"]
            )
            _ = try? client.writeString(String(describing: response))
        }
    }
}
