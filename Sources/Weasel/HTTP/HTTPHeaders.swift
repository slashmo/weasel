public struct HTTPHeaders: Equatable {
	private(set) var storage: [(String, String)]

	public init(_ headers: [(String, String)]) {
		storage = headers
	}

	public subscript(name: String) -> [String] {
		storage.reduce(into: []) { result, next in
			let (key, value) = next
			if key.lowercased() == name.lowercased() {
				result.append(value)
			}
		}
	}

	public mutating func add(name: String, value: String) {
		storage.append((name, value))
	}

	public mutating func upsert(name: String, value: String) {
		remove(name: name)
		add(name: name, value: value)
	}

	public mutating func remove(name: String) {
		storage.removeAll(where: { $0.0.lowercased() == name.lowercased() })
	}

	public static func == (lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
		guard lhs.storage.count == rhs.storage.count else { return false }
		let lhsNames = Set(lhs.storage.map { $0.0.lowercased() })
		let rhsNames = Set(rhs.storage.map { $0.0.lowercased() })
		guard lhsNames == rhsNames else { return false }

		for name in lhsNames {
			guard lhs[name].sorted() == rhs[name].sorted() else {
				return false
			}
		}

		return true
	}
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: (String, String)...) {
		self.init(elements)
	}
}

extension HTTPHeaders: CustomStringConvertible {
	public var description: String {
		var description = ""
		for (key, value) in storage {
			description += "\(key): \(value)\r\n"
		}
		return description
	}
}
