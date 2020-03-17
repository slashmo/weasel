import Foundation

let httpHeader = zip(
	prefix(while: { $0 != ":" }),
	literal(":"),
	zeroOrMoreSpaces,
	prefix(while: { !$0.isNewline })
).map { (String($0.0), String($0.3).trimmingCharacters(in: .whitespaces)) }

/// Parses HTTP headers from a string in order of appearance.
///
/// - warning: Validity of header keys/values is **not** being checked in this parser as
/// [recommended by the rfc](https://www.ietf.org/rfc/rfc7230.html#section-3.2.4).
/// Instead, headers will be validated on a per-key basis at a later stage, after ensuring that the entire message header is valid.
public let httpHeaders = zeroOrMore(httpHeader, separatedBy: crlf)
