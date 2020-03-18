import Foundation

/// An object that can notify a long-running process when a shut down was requested.
public protocol ShutdownNotifier: AnyObject {
	/// Callback to be executed once the process should be shut down.
	var onShutdown: (() -> Void)? { get set }
}

/// Tells its owner when to shut down based on `SIGTERM` & `SIGINT` signals.
public final class SignalBasedShutdownNotifier: ShutdownNotifier {
	public var onShutdown: (() -> Void)?

	private let signalQueue = DispatchQueue(label: "codes.slashmo.weasel.SignalBasedShutdownNotifier")
	private var signalSources = [DispatchSourceSignal]()

	public init() {
		addSignal(SIGTERM)
		addSignal(SIGINT)
	}

	private func addSignal(_ code: Int32) {
		let source = DispatchSource.makeSignalSource(signal: code, queue: signalQueue)
		source.setEventHandler { [weak self] in
			print() // insert new line after ^C
			self?.onShutdown?()
		}
		source.resume()
		signalSources.append(source)
		signal(code, SIG_IGN)
	}
}
