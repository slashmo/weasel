import Async

public final class DefaultHTTPResponder: HTTPResponder {
    public init() {}

    public func respond(to request: HTTPRequest) -> Future<HTTPResponse, HTTPError> {
        let promise = Promise<HTTPResponse, HTTPError>()
        promise.report(.success(HTTPResponse(status: .ok, body: "Hello, Weasel!")))
        return promise
    }
}
