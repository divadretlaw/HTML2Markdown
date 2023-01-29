import XCTest
@testable import HTML2Markdown

final class MarkdownTests: XCTestCase {
    private func doConvert(_ html: String) throws -> String {
        return try HTMLParser()
            .parse(html: html)
            .toMarkdown(options: .mastodon)
    }
    
    func testExampleStatus() throws {
        let html = "<p>&quot;I lost my inheritance with one wrong digit on my sort code&quot;</p><p><a href=\"https://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">theguardian.com/money/2019/dec</span><span class=\"invisible\">/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code</span></a></p>"
        
        XCTAssertEqual(try doConvert(html),
                       "\"I lost my inheritance with one wrong digit on my sort code\"\n\n[theguardian.com/money/2019/dec…](https://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code)")
    }
}
