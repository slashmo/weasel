/// The first line of every HTTP request.
public struct HTTPRequestLine {
    public let method: HTTPMethod
    public let path: String
    public let version: HTTPVersion
}

/// Parses the `HTTPRequestLine` of a request string.
public let httpRequestLine = zip(
    httpMethod,
    space,
    prefix(while: { !$0.isWhitespace }),
    space,
    httpVersion,
    crlf
).map { HTTPRequestLine(method: $0.0, path: String($0.2), version: $0.4) }
