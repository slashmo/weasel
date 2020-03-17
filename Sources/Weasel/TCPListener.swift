import Foundation
import Logging

public final class TCPListener {
	private let address: String
	private let logger = Logger(label: "codes.slashmo.weasel.TCPListener")
	private let shutdownNotifier: ShutdownNotifier
	private(set) var isRunning = true

	private init(address: String, shutdownNotifier: ShutdownNotifier) {
		self.address = address
		self.shutdownNotifier = shutdownNotifier
	}

	public func start() {
		shutdownNotifier.onShutdown = stop
		logger.info(#"🎧 TCP listener running on "\#(address)""#)
		while isRunning {}
	}

	func stop() {
		logger.info(#"🙅‍♂️ Gracefully shutting down TCP listener on "\#(address)""#)
		isRunning = false
	}
}

extension TCPListener {
	public static func bound(
		to address: String,
		shutdownNotifier: ShutdownNotifier = SignalBasedShutdownNotifier()
	) -> TCPListener {
		TCPListener(address: address, shutdownNotifier: shutdownNotifier)
	}
}
