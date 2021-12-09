import XCTest
@testable import HTML2Markdown

final class HTMLParserTests: XCTestCase {
	private func doParse(_ html: String) throws -> String {
		let tokens = try Tokenizer().tokenize(html: html)
		let root = try HTMLParser().parse(tokens: tokens)
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
		XCTAssertEqual(parsed, "[one]{element [:]}[hello]{/element}[two]")
	}

	func testOneElementWithAttribute() throws {
		let html = "one< element att1 = \"one'one\" >hello< / element >two"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "[one]{element [\"att1\": \"one\\'one\"]}[hello]{/element}[two]")
	}

	func testTwoElement() throws {
		let html = "< one >first< / one >< two >second< / two >"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "{one [:]}[first]{/one}{two [:]}[second]{/two}")
	}

	func testAutoClosing() throws {
		let html = "< br / >"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "{br [:]/}")
	}

	func testDeeplyNested() throws {
		let html = "<body><h1>heading!</ h1 >< p>paragraph with <strong>highlight< /strong><br/>and <a href=\"google.com\"><em>link</em>.< / a></p></ body>"
		let parsed = try self.doParse(html)
		XCTAssertEqual(parsed, "{body [:]}{h1 [:]}[heading!]{/h1}{p [:]}[paragraph with ]{strong [:]}[highlight]{/strong}{br [:]/}[and ]{a [\"href\": \"google.com\"]}{em [:]}[link]{/em}[.]{/a}{/p}{/body}")
	}
}

// MARK: - crude extensions to turn the parsed DOM into a string, for making assertions... with <> turned into {} and textual element content surrounded with []

extension Element: CustomStringConvertible {
	public var description: String {
		var result = ""

		switch self {
		case let .root(children):
			for child in children {
				result += String(describing: child)
			}
		case let .element(tag, children):
			if children.count > 0 {
				result += "{\(tag.name) \(String(describing: tag.attributes))}"
				for child in children {
					result += String(describing: child)
				}
				result += "{/\(tag.name)}"
			} else {
				result += "{\(tag.name) \(String(describing: tag.attributes))/}"
			}
		case let .text(text):
			result += "[\(text)]"
		}

		return result
	}
}

//extension HTMLText: CustomStringConvertible {
//	public var description: String {
//		"[\(text)]"
//	}
//}
//
//extension HTMLElement: CustomStringConvertible {
//	public var description: String {
//		var result = ""
//
//		switch self.content {
//		case .root(children: let children):
//			for child in children {
//				result += String(describing: child)
//			}
//		case .opening:
//			result += "{"
//		case .openingWithName(let tagName, let attributes):
//			result += "{\(tagName) \(String(describing: attributes))"
//		case .openingWithNameAndMaybeAttribute(let tagName, let attributes):
//			result += "{\(tagName) \(String(describing: attributes))"
//		case .openingWithNameAttributeName(let tagName, let attributes, let attributeName):
//			result += "{\(tagName) \(String(describing: attributes)) \(attributeName))"
//		case .openingWithNameAttributeNameEquals(let tagName, let attributes, let attributeName):
//			result += "{\(tagName) \(String(describing: attributes)) \(attributeName))="
//		case .openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, _):
//			result += "{\(tagName) \(String(describing: attributes)) \(attributeName))='\(attributeValue)"
//		case .opened(let tagName, let attributes, let children):
//			result += "{\(tagName) \(String(describing: attributes))}"
//			for child in children {
//				result += String(describing: child)
//			}
//		case .closing(let tagName, let attributes, let children):
//			result += "{\(tagName) \(String(describing: attributes))}"
//			for child in children {
//				result += String(describing: child)
//			}
//			result += "{"
//		case .closingWithName(let openingTagName, let closingTagName, let attributes, let children):
//			result += "{\(openingTagName) \(String(describing: attributes))}"
//			for child in children {
//				result += String(describing: child)
//			}
//			result += "{/\(closingTagName)"
//		case .closed(let tagName, let attributes, let children):
//			if children.count > 0 {
//				result += "{\(tagName) \(String(describing: attributes))}"
//				for child in children {
//					result += String(describing: child)
//				}
//				result += "{/\(tagName)}"
//			} else {
//				result += "{\(tagName) \(String(describing: attributes))/}"
//			}
//		}
//
//		return result
//	}
//
//	func testReminders() {
//		XCTFail("<p>mismatched case in tags - see crs SNT</P>")
//	}
//}
