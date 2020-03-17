@testable import Weasel
import XCTest

final class TCPListenerTests: XCTestCase {
	func testItHandlesShutdownSignals() {
		let notifier = MockShutdownNotifier()
		let listener = TCPListener.bound(to: "localhost:8080", shutdownNotifier: notifier)

		DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
			XCTAssertNotNil(notifier.onShutdown)
			notifier.notify()
		}

		XCTAssertNil(notifier.onShutdown)
		listener.start()
	}
}
