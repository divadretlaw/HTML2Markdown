import XCTest
@testable import HTMLParser

final class TokenizerTests: XCTestCase {
	func testOpeningTagStart() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "<"), [.openingTagStart("<"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "<b"), [
			.openingTagStart("<"),
			.text("b"),
			.endOfFile
		])
		XCTAssertEqual(try t.tokenize(html: "<  "), [
			.openingTagStart("<"),
			.whitespace("  "),
			.endOfFile
		])
	}

	func testClosingTagStart() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "</"), [.closingTagStart("</"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "< /"), [.closingTagStart("< /"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "<//"), [
			.closingTagStart("</"),
			.text("/"),
			.endOfFile
		])
	}

	func testTagEnd() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: ">"), [.tagEnd(">"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: ">p"), [
			.tagEnd(">"),
			.text("p"),
			.endOfFile
		])
	}

	func testAutoClosingTagEnd() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "/>"), [.autoClosingTagEnd("/>"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "/ >"), [.autoClosingTagEnd("/ >"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "/ >p"), [
			.autoClosingTagEnd("/ >"),
			.text("p"),
			.endOfFile
		])
	}

	func testEqualSign() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "="),[.equalsSign("="), .endOfFile])
	}

	func testQuote() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "'"), [.quote("'"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "\""), [.quote("\""), .endOfFile])
	}

	func testWhiteSpace() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: " "), [.whitespace(" "), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "\t"), [.whitespace("\t"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "\n"), [.whitespace("\n"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "  "), [.whitespace("  "), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: " \t"), [.whitespace(" \t"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "\t "), [.whitespace("\t "), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: " \n"), [.whitespace(" \n"), .endOfFile])
		XCTAssertEqual(try t.tokenize(html: "\n "), [.whitespace("\n "), .endOfFile])
	}

	func testText() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "💩"),
					   [
						.text("💩"),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "/hi"),
					   [
						.text("/hi"),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "hi there"),
					   [
						.text("hi"),
						.whitespace(" "),
						.text("there"),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "h<"),
					   [
						.text("h"),
						.openingTagStart("<"),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "h>"),
					   [
						.text("h"),
						.tagEnd(">"),
						.endOfFile
					   ])
		// Not great - ideally this would be `.text("h/")`
		// ¯\_(ツ)_/¯
		XCTAssertEqual(try t.tokenize(html: "h/"),
					   [
						.text("h"),
						.text("/"),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "h="),
					   [
						.text("h"),
						.equalsSign("="),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "h'"),
					   [
						.text("h"),
						.quote("'"),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "h\""),
					   [
						.text("h"),
						.quote("\""),
						.endOfFile
					   ])
		XCTAssertEqual(try t.tokenize(html: "h "),
					   [
						.text("h"),
						.whitespace(" "),
						.endOfFile
					   ])
	}

	func testOpeningTag() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "<tag>"),
					   [
						.openingTagStart("<"),
						.text("tag"),
						.tagEnd(">"),
						.endOfFile
					   ])
	}

	func testClosingTag() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "</tag>"),
					   [
						.closingTagStart("</"),
						.text("tag"),
						.tagEnd(">"),
						.endOfFile
					   ])
	}

	func testAutoClosingTag() throws {
		let t = Tokenizer()
		XCTAssertEqual(try t.tokenize(html: "<tag/>"),
					   [
						.openingTagStart("<"),
						.text("tag"),
						.autoClosingTagEnd("/>"),
						.endOfFile
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
						.endOfFile
					   ])
	}
}
