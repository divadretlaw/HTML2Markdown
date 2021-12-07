import XCTest
@testable import HTMLParser

final class ParserTests: XCTestCase {
	private func doParse(_ html: String) throws -> String {
		let tokens = try Tokenizer().tokenize(html: html)
		let root = try Parser().parse(tokens: tokens)
		return String(describing: root)
	}

	func testString() throws {
		let html = "hello"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "[hello]")
	}

	func testOneElement() throws {
		let html = "one< element >hello< / element >two"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "[one]{element}[hello]{/element}[two]")
	}

	func testTwoElement() throws {
		let html = "< one >first< / one >< two >second< / two >"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "{one}[first]{/one}{two}[second]{/two}")
	}

	func testAutoClosing() throws {
		let html = "< br / >"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "{br/}")
	}
}

// MARK: - crude extensions to turn the parsed DOM into a string, for making assertions... with <> turned into {} and textual element content surrounded with []

extension Text: CustomStringConvertible {
	public var description: String {
		"[\(text)]"
	}
}

extension Element: CustomStringConvertible {
	public var description: String {
		var result = ""

		switch self.content {
		case .root(children: let children):
			for child in children {
				result += String(describing: child)
			}
		case .opening:
			result += "{"
		case .openingWithName(let tagName):
			result += "{\(tagName)"
		case .opened(let tagName, let children):
			result += "{\(tagName)}"
			for child in children {
				result += String(describing: child)
			}
		case .closing(let tagName, let children):
			result += "{\(tagName)}"
			for child in children {
				result += String(describing: child)
			}
			result += "{"
		case .closingWithName(let openingTagName, let closingTagName, let children):
			result += "{\(openingTagName)}"
			for child in children {
				result += String(describing: child)
			}
			result += "{/\(closingTagName)"
		case .closed(let tagName, let children):
			if children.count > 0 {
				result += "{\(tagName)}"
				for child in children {
					result += String(describing: child)
				}
				result += "{/\(tagName)}"
			} else {
				result += "{\(tagName)/}"
			}
		}

		return result
	}
}
