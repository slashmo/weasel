public struct Parser<A> {
	let run: (inout Substring) -> A?
}

extension Parser {
  static var never: Parser {
    return Parser { _ in nil }
  }
}

func always<A>(_ a: A) -> Parser<A> {
  return Parser<A> { _ in a }
}

func literal(_ p: String) -> Parser<Void> {
	Parser<Void> { str in
		guard str.hasPrefix(p) else { return nil }
		str.removeFirst(p.count)
		return ()
	}
}

let int = Parser<Int> { str in
	let prefix = str.prefix(while: { $0.isNumber })
  let match = Int(prefix)
  str.removeFirst(prefix.count)
  return match
}

extension Parser {
	func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
		Parser<B> { str -> B? in
			self.run(&str).map(f)
		}
	}

	func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
    Parser<B> { str -> B? in
      let original = str
      let matchA = self.run(&str)
      let parserB = matchA.map(f)
      guard let matchB = parserB?.run(&str) else {
        str = original
        return nil
      }
      return matchB
    }
  }
}

extension Parser {
  public func run(_ str: String) -> (match: A?, rest: Substring) {
    var str = str[...]
    let match = self.run(&str)
    return (match, str)
  }
}
