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

func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
  Parser<Substring> { str in
    let prefix = str.prefix(while: p)
    str.removeFirst(prefix.count)
    return prefix
  }
}

func oneOf<A>(_ ps: [Parser<A>]) -> Parser<A> {
	Parser<A> { str -> A? in
		for p in ps {
			if let match = p.run(&str) {
				return match
			}
		}
		return nil
	}
}

func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
	Parser<(A, B)> { str -> (A, B)? in
		let original = str
		guard let matchA = a.run(&str) else { return nil }
		guard let matchB = b.run(&str) else {
			str = original
			return nil
		}
		return (matchA, matchB)
	}
}

func zip<A, B, C>(
	_ a: Parser<A>,
	_ b: Parser<B>,
	_ c: Parser<C>
) -> Parser<(A, B, C)> {
	zip(a, zip(b, c))
		.map { a, bc in (a, bc.0, bc.1) }
}

func zip<A, B, C, D>(
	_ a: Parser<A>,
	_ b: Parser<B>,
	_ c: Parser<C>,
	_ d: Parser<D>
) -> Parser<(A, B, C, D)> {
	zip(a, zip(b, c, d))
		.map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

func zip<A, B, C, D, E>(
	_ a: Parser<A>,
	_ b: Parser<B>,
	_ c: Parser<C>,
	_ d: Parser<D>,
	_ e: Parser<E>
) -> Parser<(A, B, C, D, E)> {
	zip(a, zip(b, c, d, e))
		.map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

func zip<A, B, C, D, E, F>(
	_ a: Parser<A>,
	_ b: Parser<B>,
	_ c: Parser<C>,
	_ d: Parser<D>,
	_ e: Parser<E>,
	_ f: Parser<F>
) -> Parser<(A, B, C, D, E, F)> {
	zip(a, zip(b, c, d, e, f))
		.map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}

func zeroOrMore<A>(_ p: Parser<A>, separatedBy s: Parser<Void>) -> Parser<[A]> {
	Parser<[A]> { str in
		var rest = str
		var matches = [A]()
		while let match = p.run(&str) {
			rest = str
			matches.append(match)
			if s.run(&str) == nil {
				return matches
			}
		}
		str = rest
		return matches
	}
}

let zeroOrMoreSpaces = prefix(while: { $0 == " " }).map { _ in () }

let space = literal(" ")
let crlf = literal("\r\n")

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
