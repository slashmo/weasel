@testable import Weasel

final class MockTCPListenerDelegate: TCPListenerDelegate {
    var tcpListenerDidAcceptClient: ((SocketProtocol) -> Void)?

    func tcpListener(_ listener: TCPListener, didAcceptClient client: SocketProtocol) {
        tcpListenerDidAcceptClient?(client)
    }
}
