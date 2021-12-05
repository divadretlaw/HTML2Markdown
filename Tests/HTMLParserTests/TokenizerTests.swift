import XCTest
@testable import HTMLParser

final class TokenizerTests: XCTestCase {
	func testOpeningTagStart() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: "<"), [.openingTagStart])
		XCTAssertEqual(t.tokenize(html: "< "), [.openingTagStart])
		XCTAssertEqual(t.tokenize(html: "<"), [.openingTagStart])
		XCTAssertEqual(t.tokenize(html: "< "), [.openingTagStart])
	}

	func testClosingTagStart() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: "</"), [.closingTagStart])
		XCTAssertEqual(t.tokenize(html: "< /"), [.closingTagStart])
		XCTAssertEqual(t.tokenize(html: "</ "), [.closingTagStart])
		XCTAssertEqual(t.tokenize(html: "< / "), [.closingTagStart])
		XCTAssertEqual(t.tokenize(html: "</"), [.closingTagStart])
		XCTAssertEqual(t.tokenize(html: "< / "), [.closingTagStart])
	}

	func testTagEnd() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: ">"), [.tagEnd])
	}

	func testAutoClosingTagEnd() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: "/>"), [.autoClosingTagEnd])
		XCTAssertEqual(t.tokenize(html: "/ >"), [.autoClosingTagEnd])
	}

	func testEqualSign() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: "="),[.equalsSign])
	}

	func testWhiteSpace() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: " "), [.whitespace])
		XCTAssertEqual(t.tokenize(html: "\t"), [.whitespace])
		XCTAssertEqual(t.tokenize(html: "\n"), [.whitespace])
		XCTAssertEqual(t.tokenize(html: "  "), [.whitespace])
		XCTAssertEqual(t.tokenize(html: " \t"), [.whitespace])
		XCTAssertEqual(t.tokenize(html: "\t "), [.whitespace])
		XCTAssertEqual(t.tokenize(html: " \n"), [.whitespace])
		XCTAssertEqual(t.tokenize(html: "\n "), [.whitespace])
	}

	func testQuote() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: "'"), [.quote("'")])
		XCTAssertEqual(t.tokenize(html: "\""), [.quote("\"")])
	}

	func testText() throws {
		let t = Tokenizer()
		XCTAssertEqual(t.tokenize(html: "hi"), [.text("hi")])
		XCTAssertEqual(t.tokenize(html: "/"), [.text("/")])
		XCTAssertEqual(t.tokenize(html: "/hi"), [.text("/hi")])
		XCTAssertEqual(t.tokenize(html: "/ "), [.text("/ ")])
		XCTAssertEqual(t.tokenize(html: "/\t"), [.text("/\t")])
		XCTAssertEqual(t.tokenize(html: "/ hi"), [.text("/ hi")])
		XCTAssertEqual(t.tokenize(html: "/\thi"), [.text("/\thi")])
	}
}
