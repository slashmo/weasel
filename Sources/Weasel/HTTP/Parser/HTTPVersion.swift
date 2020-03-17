/// The version of the HTTP protocol being used.
///
/// - seealso: [HTTP versioning](https://www.ietf.org/rfc/rfc7230.html#section-2.6)
public struct HTTPVersion: Equatable {
	public let major: Int
	public let minor: Int
}

/// Parses the `HTTPVersion` from a string.
public let httpVersion = zip(
	literal("HTTP/"),
	int,
	literal("."),
	int
).map { HTTPVersion(major: $0.1, minor: $0.3) }
