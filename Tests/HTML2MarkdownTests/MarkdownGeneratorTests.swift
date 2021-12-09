import XCTest
@testable import HTML2Markdown

final class MarkdownGeneratorTests: XCTestCase {
	private func doConvert(_ html: String) throws -> String {
		return try HTMLParser()
			.parse(html: html)
			.toMarkdownWithError()
	}

	func testPlainString() throws {
		let html = "hello"
		XCTAssertEqual(try doConvert(html),
					   "hello")
	}

	func testOneParagraph() throws {
		let html = "<p>hello</p>"
		XCTAssertEqual(try doConvert(html),
					   "hello")
	}

	func testTwoParagraphs() throws {
		let html = "<p>hello</p><p>world</p>"
		XCTAssertEqual(try doConvert(html),
					   "hello\n\nworld")
	}

	func testLineBreak() throws {
		let html = "hello<br/>world"
		XCTAssertEqual(try doConvert(html),
					   "hello  \nworld")
	}

	func testTrailingLineBreak() throws {
		let html = "<p>hello<br/></p><p>world</p>"
		XCTAssertEqual(try doConvert(html),
					   "hello\n\nworld")
	}

	func testEmphasis() throws {
		let html = "<em>hello</em>"
		XCTAssertEqual(try doConvert(html),
					   "_hello_")
	}

	func testStrong() throws {
		let html = "<strong>hello</strong>"
		XCTAssertEqual(try doConvert(html),
					   "**hello**")
	}

	func testAnchor() throws {
		let html = "<a href=\"https://daringsnowball.net/\">link</a>"
		XCTAssertEqual(try doConvert(html),
					   "[link](https://daringsnowball.net/)")

	}

	func testAnchorWithoutHrefAttribute() throws {
		let html = "<a ref=\"https://daringsnowball.net/\">link</a>"
		XCTAssertEqual(try doConvert(html),
					   "link")

	}

	func testUnorderedList() throws {
		let html = "<ul><li>one</li><li>two</li><li>three</li></ul>"
		XCTAssertEqual(try doConvert(html),
					   "* one\n* two\n* three")
	}

	func testUnorderedListWithTextBefore() throws {
		let html = "text<ul><li>one</li><li>two</li><li>three</li></ul>"
		XCTAssertEqual(try doConvert(html),
					   "text\n\n* one\n* two\n* three")
	}

	func testUnorderedListWithTextAfter() throws {
		let html = "<ul><li>one</li><li>two</li><li>three</li></ul>text"
		XCTAssertEqual(try doConvert(html),
					   "* one\n* two\n* three\n\ntext")
	}

	func testOrderedList() throws {
		let html = "<ol><li>one</li><li>two</li><li>three</li></ol>"
		XCTAssertEqual(try doConvert(html),
					   "1 one\n2 two\n3 three")
	}

	func testOrderedListWithTextBefore() throws {
		let html = "text<ol><li>one</li><li>two</li><li>three</li></ol>"
		XCTAssertEqual(try doConvert(html),
					   "text\n\n1 one\n2 two\n3 three")
	}

	func testOrderedListWithTextAfter() throws {
		let html = "<ol><li>one</li><li>two</li><li>three</li></ol>text"
		XCTAssertEqual(try doConvert(html),
					   "1 one\n2 two\n3 three\n\ntext")
	}

	private func doTestInertTag(_ tagName: String) throws {
		let html = "<\(tagName)>text</\(tagName)>"
		XCTAssertEqual(try doConvert(html),
					   "text")
	}

	func testInertTags() throws {
		try doTestInertTag("span")
		try doTestInertTag("div")
	}
}
