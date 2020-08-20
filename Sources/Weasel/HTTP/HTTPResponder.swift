import Async

public protocol HTTPResponder {
    func respond(to request: HTTPRequest) -> Future<HTTPResponse, HTTPError>
}
