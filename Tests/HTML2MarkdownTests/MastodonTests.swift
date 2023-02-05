import XCTest
@testable import HTML2Markdown

final class MarkdownTests: XCTestCase {
    private func doConvert(_ html: String) throws -> String {
        return try HTMLParser()
            .parse(html: html)
            .markdownFormatted(options: .mastodon)
    }
    
    func testExampleStatus() throws {
        let html = "<p>&quot;I lost my inheritance with one wrong digit on my sort code&quot;</p><p><a href=\"https://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://www.</span><span class=\"ellipsis\">theguardian.com/money/2019/dec</span><span class=\"invisible\">/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code</span></a></p>"
        
        XCTAssertEqual(try doConvert(html),
                       "\"I lost my inheritance with one wrong digit on my sort code\"\n\n[theguardian.com/money/2019/dec…](https://www.theguardian.com/money/2019/dec/07/i-lost-my-193000-inheritance-with-one-wrong-digit-on-my-sort-code)")
    }
    
    func testMarkdownWithinMastodonContent() throws {
        let html = "<p># Header</p><p>Other Header<br>===========</p><p>## Final Header ##</p><p>Text: *bold*<br>Text: _italic_<br>Text: __double underscore__<br>Text: **double asterisk**<br>Text: `code`</p><p>&gt; This is a block quote</p><p>*  Starred<br>*  List</p><p>+  Plus<br>+  List</p><p>-  Minus<br>-  List</p><p>    Code by indentation</p><p>[LINK](<a href=\"http://apple.com\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">http://</span><span class=\"\">apple.com</span><span class=\"invisible\"></span></a>)</p><p>[Footnote Link][]</p><p>Rule<br>* * * </p><p>Also rule<br>- - -</p><p>Also Rule<br>------------</p><p>[Footnote Link]: <a href=\"http://google.com\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">http://</span><span class=\"\">google.com</span><span class=\"invisible\"></span></a> \"Google\"</p>"
        print(try doConvert(html))
    }
    
    func testWeirdFormat1() throws {
        let html = "<p>It\'s  ̶<a href=\"https://newsie.social/tags/%CC%B6f%CC%B6o%CC%B6l%CC%B6l%CC%B6o%CC%B6w%CC%B6f%CC%B6r%CC%B6i%CC%B6d%CC%B6a%CC%B6y%CC%B6\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>̶f̶o̶l̶l̶o̶w̶f̶r̶i̶d̶a̶y̶</span></a> thursday and here are some cool Newsie folks to follow.</p><p>Matthew Bennett<br><span class=\"h-card\"><a href=\"https://newsie.social/@matthewbennett\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>matthewbennett</span></a></span> </p><p>Steve Silberman<br><span class=\"h-card\"><a href=\"https://newsie.social/@stevesilberman\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>stevesilberman</span></a></span> </p><p>The Bulwark<br><span class=\"h-card\"><a href=\"https://newsie.social/@bulwarkonline\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>bulwarkonline</span></a></span> </p><p>Ben Greenberg<br><span class=\"h-card\"><a href=\"https://newsie.social/@beng\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>beng</span></a></span> </p><p><span class=\"h-card\"><a href=\"https://newsie.social/@Lee_in_Iowa\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>Lee_in_Iowa</span></a></span><br><span class=\"h-card\"><a href=\"https://newsie.social/@Lee_in_Iowa\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>Lee_in_Iowa</span></a></span> </p><p>Freddy Tran Nager<br><span class=\"h-card\"><a href=\"https://newsie.social/@freddytrannager\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>freddytrannager</span></a></span> </p><p>Freedom of the Press<br><span class=\"h-card\"><a href=\"https://newsie.social/@freedomofpress\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>freedomofpress</span></a></span> </p><p>Stan Wise<br><span class=\"h-card\"><a href=\"https://newsie.social/@stanwise\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>stanwise</span></a></span></p>"
        do {
            print(try doConvert(html))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testWeirdFormat2() throws {
        let html = "<p>Watched this with the trial version of the second Coming of <a href=\"https://cinematheque.social/tags/Movist\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>Movist</span></a> and I must say I\'m quite impressed with the quality. Definitely because The Beast is a pretty dark, noirish affair. The screens are from a copy available on Archive (not a real DVD rip) which tend to be riddled with digital artefacts but here\'s a nice, soft filmic grain..</p><p>What are your favourite <a href=\"https://cinematheque.social/tags/MediaPlayer\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>MediaPlayer</span></a>‍s, <a href=\"https://cinematheque.social/tags/Cinemastodon\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>Cinemastodon</span></a>‍s, and why? Mac, Linux, PC? Bring it on! <a href=\"https://cinematheque.social/tags/software\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>software</span></a> <a href=\"https://cinematheque.social/tags/opensource\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>opensource</span></a> <a href=\"https://cinematheque.social/tags/film\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>film</span></a></p>"
        do {
            print(try doConvert(html))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testWeirdFormat3() throws {
        let html = "<p>Watched this with the trial version of the second Coming of <a href=\"https://cinematheque.social/tags/Movist\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>Movist</span></a> and I must say I\'m quite impressed with the quality. Definitely because The Beast is a pretty dark, noirish affair. The screens are from a copy available on Archive (not a real DVD rip) which tend to be riddled with digital artefacts but here\'s a nice, soft filmic grain..</p><p>What are your favourite <a href=\"https://cinematheque.social/tags/MediaPlayer\">#<span>MediaPlayer</span></a>‍</p>"
        do {
            print(try doConvert(html))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
