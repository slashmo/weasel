import Weasel

let address = try SocketAddress(resolvingHost: "localhost", port: 8080)
let server = try HTTPServer(tcpListener: .bound(to: address))
try server.start()
