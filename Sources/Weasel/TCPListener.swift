import Foundation
import Logging

protocol TCPListenerDelegate: AnyObject {
	func tcpListener(_ listener: TCPListener, didAcceptClient client: SocketProtocol)
}

public final class TCPListener {
	weak var delegate: TCPListenerDelegate?

	private let address: SocketAddress
	private let socket: SocketProtocol
	private let logger = Logger(label: "codes.slashmo.weasel.TCPListener")
	private let shutdownNotifier: ShutdownNotifier
	private var isRunning = true

	private init(address: SocketAddress, shutdownNotifier: ShutdownNotifier, socket: SocketProtocol) {
		self.address = address
		self.shutdownNotifier = shutdownNotifier
		self.socket = socket
	}

	public func start() throws {
		shutdownNotifier.onShutdown = stop
		try socket.listen(backlog: SOMAXCONN)
		while isRunning, let clientSocket = try socket.accept() {
			try clientSocket.setOption(level: SOL_SOCKET, name: SO_REUSEADDR, value: 1)
			delegate?.tcpListener(self, didAcceptClient: clientSocket)
		}
	}

	func stop() {
		logger.info(#"🙅‍♂️ Gracefully shutting down TCP listener on "\#(address)""#)
		try? socket.close()
		isRunning = false
	}
}

extension TCPListener {
	public static func bound(
		to address: SocketAddress,
		shutdownNotifier: ShutdownNotifier = SignalBasedShutdownNotifier(),
		makeSocket: (_ protocolFamily: CInt) throws -> SocketProtocol = Socket.init(protocolFamily:)
	) throws -> TCPListener {
		let socket = try makeSocket(address.protocolFamily)
		do {
			try socket.setOption(level: SOL_SOCKET, name: SO_REUSEADDR, value: 1)
			try socket.bind(to: address)
		} catch {
			try socket.close()
			throw error
		}
		return TCPListener(address: address, shutdownNotifier: shutdownNotifier, socket: socket)
	}
}
