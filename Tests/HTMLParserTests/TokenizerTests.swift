import XCTest
@testable import HTMLParser

final class TokenizerTests: XCTestCase {
	func testOpeningTagStart() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "<"), [.openingTagStart("<")])
		XCTAssertEqual(try t.tokenize(html: "<b"), [
			.openingTagStart("<"),
			.text("b")
		])
		XCTAssertEqual(try t.tokenize(html: "<  "), [
			.openingTagStart("<"),
			.whitespace("  ")
		])
	}

	func testClosingTagStart() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "</"), [.closingTagStart("</")])
		XCTAssertEqual(try t.tokenize(html: "< /"), [.closingTagStart("< /")])
		XCTAssertEqual(try t.tokenize(html: "<//"), [
			.closingTagStart("</"),
			.text("/")
		])
	}

	func testTagEnd() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: ">"), [.tagEnd(">")])
		XCTAssertEqual(try t.tokenize(html: ">p"), [
			.tagEnd(">"),
			.text("p")
		])
	}

	func testAutoClosingTagEnd() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "/>"), [.autoClosingTagEnd("/>")])
		XCTAssertEqual(try t.tokenize(html: "/ >"), [.autoClosingTagEnd("/ >")])
		XCTAssertEqual(try t.tokenize(html: "/ >p"), [
			.autoClosingTagEnd("/ >"),
			.text("p")
		])
	}

	func testEqualSign() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "="),[.equalsSign("=")])
	}

	func testQuote() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "'"), [.quote("'")])
		XCTAssertEqual(try t.tokenize(html: "\""), [.quote("\"")])
	}

	func testWhiteSpace() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: " "), [.whitespace(" ")])
		XCTAssertEqual(try t.tokenize(html: "\t"), [.whitespace("\t")])
		XCTAssertEqual(try t.tokenize(html: "\n"), [.whitespace("\n")])
		XCTAssertEqual(try t.tokenize(html: "  "), [.whitespace("  ")])
		XCTAssertEqual(try t.tokenize(html: " \t"), [.whitespace(" \t")])
		XCTAssertEqual(try t.tokenize(html: "\t "), [.whitespace("\t ")])
		XCTAssertEqual(try t.tokenize(html: " \n"), [.whitespace(" \n")])
		XCTAssertEqual(try t.tokenize(html: "\n "), [.whitespace("\n ")])
	}

	func testText() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "💩"),
					   [
						.text("💩"),
					   ])
		XCTAssertEqual(try t.tokenize(html: "/hi"),
					   [
						.text("/hi"),
					   ])
		XCTAssertEqual(try t.tokenize(html: "hi there"),
					   [
						.text("hi"),
						.whitespace(" "),
						.text("there"),
					   ])
		XCTAssertEqual(try t.tokenize(html: "h<"),
					   [
						.text("h"),
						.openingTagStart("<")
					   ])
		XCTAssertEqual(try t.tokenize(html: "h>"),
					   [
						.text("h"),
						.tagEnd(">")
					   ])
		// Not great - ideally this would be `.text("h/")`
		// ¯\_(ツ)_/¯
		XCTAssertEqual(try t.tokenize(html: "h/"),
					   [
						.text("h"),
						.text("/")
					   ])
		XCTAssertEqual(try t.tokenize(html: "h="),
					   [
						.text("h"),
						.equalsSign("=")
					   ])
		XCTAssertEqual(try t.tokenize(html: "h'"),
					   [
						.text("h"),
						.quote("'")
					   ])
		XCTAssertEqual(try t.tokenize(html: "h\""),
					   [
						.text("h"),
						.quote("\"")
					   ])
		XCTAssertEqual(try t.tokenize(html: "h "),
					   [
						.text("h"),
						.whitespace(" ")
					   ])
	}

	func testOpeningTag() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "<tag>"),
					   [
						.openingTagStart("<"),
						.text("tag"),
						.tagEnd(">")
					   ])
	}

	func testClosingTag() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "</tag>"),
					   [
						.closingTagStart("</"),
						.text("tag"),
						.tagEnd(">")
					   ])
	}

	func testAutoClosingTag() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "<tag/>"),
					   [
						.openingTagStart("<"),
						.text("tag"),
						.autoClosingTagEnd("/>")
					   ])
	}

	func testLongerHTML() throws {
		let t = Tokenizer()
		let html = """
		One
		< p key="value"> Two  < strong>Three< / strong> Four <br / >
		</p>
		"""

		XCTAssertEqual(try t.tokenize(html: html),
					   [
						.text("One"),
						.whitespace("\n"),
						.openingTagStart("<"),
						.whitespace(" "),
						.text("p"),
						.whitespace(" "),
						.text("key"),
						.equalsSign("="),
						.quote("\""),
						.text("value"),
						.quote("\""),
						.tagEnd(">"),
						.whitespace(" "),
						.text("Two"),
						.whitespace("  "),
						.openingTagStart("<"),
						.whitespace(" "),
						.text("strong"),
						.tagEnd(">"),
						.text("Three"),
						.closingTagStart("< /"),
						.whitespace(" "),
						.text("strong"),
						.tagEnd(">"),
						.whitespace(" "),
						.text("Four"),
						.whitespace(" "),
						.openingTagStart("<"),
						.text("br"),
						.whitespace(" "),
						.autoClosingTagEnd("/ >"),
						.whitespace("\n"),
						.closingTagStart("</"),
						.text("p"),
						.tagEnd(">"),
					   ])
	}
}
