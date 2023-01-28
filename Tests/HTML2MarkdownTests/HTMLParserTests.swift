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
        let html = "one< element >hello< / ELEMENT >two"
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
    
    func testEmptySpan() throws {
        let html = "<span class=\"theClass\"></span>"
        let parsed = try self.doParse(html)
        XCTAssertEqual(parsed, "{span [\"class\": \"theClass\"]/}")
    }
    
    func testUnclosedParagraph() throws {
        let html = "<p>oh no"
        XCTAssertThrowsError(try self.doParse(html)) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
    }
    
    func testUnclosedLineBreak() throws {
        XCTAssertEqual(try self.doParse("<br>"), "{br [:]/}")
        XCTAssertEqual(try self.doParse("< br >"), "{br [:]/}")
        XCTAssertEqual(try self.doParse("<br attributeName = \"value\">"), "{br [\"attributeName\": \"value\"]/}")
        XCTAssertEqual(try self.doParse("<br attributeName = \"value\" >"), "{br [\"attributeName\": \"value\"]/}")
    }
    
    func testUnclosedLineBreak_cannotImplicitlyClose() throws {
        XCTAssertThrowsError(try self.doParse("<br attributeName")) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
        XCTAssertThrowsError(try self.doParse("<br attributeName ")) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
        XCTAssertThrowsError(try self.doParse("<br attributeName =")) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
        XCTAssertThrowsError(try self.doParse("<br attributeName = ")) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
        XCTAssertThrowsError(try self.doParse("<br attributeName = \"")) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
        XCTAssertThrowsError(try self.doParse("<br attributeName = \"value")) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
        XCTAssertThrowsError(try self.doParse("<br attributeName = \"value" )) { error in
            XCTAssertEqual(String(describing: error), "unexpected(tokenType: HTML2Markdown.TokenType.endOfFile)")
        }
    }
    
    func testMismatchedTagName() throws {
        XCTAssertThrowsError(try self.doParse("<p>hello</div>")) { error in
            XCTAssertEqual(String(describing: error), "mismatchedOpeningClosingTags(openingTagName: \"p\", closingTagName: \"div\")")
        }
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
