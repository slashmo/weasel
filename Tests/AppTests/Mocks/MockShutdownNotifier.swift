import App

final class MockShutdownNotifier: ShutdownNotifier {
	var onShutdown: (() -> Void)?

	func notify() {
		onShutdown?()
	}
}
