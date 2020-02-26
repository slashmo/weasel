/// The method to be performed on a resource.
public enum HTTPMethod: String, CaseIterable {
	/// Transfer a current representation of the target resource.
	case get = "GET"
	/// Same as GET, but only transfer the status line and header section.
	case head = "HEAD"
	/// Perform resource-specific processing on the request payload.
	case post = "POST"
	/// Replace all current representations of the resource with the request payload.
	case put = "PUT"
	/// Remove all current representations of the target resource.
	case delete = "DELETE"
	/// Establish a tunnel to the server identified by the target resource.
	case connect = "CONNECT"
	/// Describe the communication options for the target resource.
	case options = "OPTIONS"
	/// Perform a message loop-back test along the path to the target resource.
	case trace = "TRACE"
}

/// Parses one of the `HTTPMethod`s from a string.
///
/// - note: `HTTPMethod`s are case-sensitive an always uppercased.
public let httpMethod: Parser<HTTPMethod> = oneOf(
	HTTPMethod.allCases.map { method in
		literal(method.rawValue).map { method }
	}
)
