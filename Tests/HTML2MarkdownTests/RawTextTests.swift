import XCTest
@testable import HTML2Markdown

final class RawTextTests: XCTestCase {
    private func doConvert(_ html: String, options: RawTextGenerator.Options = []) throws -> String {
        return try HTMLParser()
            .parse(html: html)
            .rawText(options: options)
    }
    
    func testExampleStatus() throws {
        let html = "<p>&quot;I lost my inheritance with one wrong digit on my sort code&quot;</p><p><a href=\"https://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">theguardian.com/money/2019/dec</span><span class=\"invisible\">/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code</span></a></p>"
        
        XCTAssertEqual(try doConvert(html),
                       "\"I lost my inheritance with one wrong digit on my sort code\"\n\nhttps://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code")
    }
    
    func testExampleStatusKeepLinkText() throws {
        let html = "<p>&quot;I lost my inheritance with one wrong digit on my sort code&quot;</p><p><a href=\"https://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">theguardian.com/money/2019/dec</span><span class=\"invisible\">/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code</span></a></p>"
        
        XCTAssertEqual(try doConvert(html, options: [.mastodon, .keepLinkText]),
                       "\"I lost my inheritance with one wrong digit on my sort code\"\n\ntheguardian.com/money/2019/dec…")
    }
    
    func testMarkdownWithinMastodonContent() throws {
        let html = "<p># Header</p><p>Other Header<br>===========</p><p>## Final Header ##</p><p>Text: *bold*<br>Text: _italic_<br>Text: __double underscore__<br>Text: **double asterisk**<br>Text: `code`</p><p>&gt; This is a block quote</p><p>*  Starred<br>*  List</p><p>+  Plus<br>+  List</p><p>-  Minus<br>-  List</p><p>    Code by indentation</p><p>[LINK](<a href=\"http://apple.com\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">http://</span><span class=\"\">apple.com</span><span class=\"invisible\"></span></a>)</p><p>[Footnote Link][]</p><p>Rule<br>* * * </p><p>Also rule<br>- - -</p><p>Also Rule<br>------------</p><p>[Footnote Link]: <a href=\"http://google.com\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">http://</span><span class=\"\">google.com</span><span class=\"invisible\"></span></a> \"Google\"</p>"
        print(try doConvert(html))
    }
}
