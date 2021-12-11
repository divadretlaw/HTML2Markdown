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
					   "1. one\n2. two\n3. three")
	}

	func testOrderedListWithTextBefore() throws {
		let html = "text<ol><li>one</li><li>two</li><li>three</li></ol>"
		XCTAssertEqual(try doConvert(html),
					   "text\n\n1. one\n2. two\n3. three")
	}

	func testOrderedListWithTextAfter() throws {
		let html = "<ol><li>one</li><li>two</li><li>three</li></ol>text"
		XCTAssertEqual(try doConvert(html),
					   "1. one\n2. two\n3. three\n\ntext")
	}

	func testFilterElementsWithNoContent() throws {
		let html = """
<p><span><span>First para</span></span></p>
<p><span><span><span><span>Second para - <a href="https://daringsnowball.net/">link text</a><span><span><span><span><br />
<span> </span></span></span></span></span></span></span></span></span></p>
<p> </p>
"""
		XCTAssertEqual(try doConvert(html),
					   "First para\n\nSecond para - [link text](https://daringsnowball.net/)")
	}

	func testTrimsParagraphContent() throws {
		let html = "<p> first </p><p> second </p>"
		XCTAssertEqual(try doConvert(html),
					   "first\n\nsecond")
	}

	func testReplacesIdeographicSpace() throws {
		// "U+3000 Ideographic Space"
		XCTAssertEqual(try doConvert("a　b"), "a b")
	}

	func testCollapsesMultipleWhiteSpace() throws {
		// the first space in the input string is "U+3000 Ideographic Space"
		XCTAssertEqual(try doConvert("a\t\n　\r b"), "a b")
	}

	func testEmptySpan() throws {
		let html = "<span class=\"theClass\"></span>"
		XCTAssertEqual(try doConvert(html),
					   "")
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
