//
//  HTMLParser.swift
//  HTML2Markdown
//
//  Created by Matthew Flint on 2021-12-07.
//

import Foundation
@preconcurrency import SwiftSoup

public struct HTMLParser: Sendable {
    let baseUri: String?
    let parser: Parser
    
    public init(baseUri: String? = nil, parser: Parser = Parser.htmlParser()) {
        self.baseUri = baseUri
        self.parser = parser
    }
    
    public func parse(html: String, evaluateMarkdown: Bool = false) throws -> Node {
        let htmlString: String
        if evaluateMarkdown {
            htmlString = html
                .replacingOccurrences(of: "```(.|\n)*?```", with: "<pre><code>$0</code></pre>", options: [.regularExpression])
                .replacingOccurrences(of: "<pre><code>```", with: "<pre><code>")
                .replacingOccurrences(of: "```</code></pre>", with: "</code></pre>")
                .replacingOccurrences(of: "`.*?`", with: "<code>$0</code>", options: [.regularExpression])
                .replacingOccurrences(of: "<code>`", with: "<code>")
                .replacingOccurrences(of: "`</code>", with: "</code>")
        } else {
            htmlString = html
        }
        return if let baseUri {
            try SwiftSoup.parse(htmlString, baseUri, parser)
        } else {
            try SwiftSoup.parse(htmlString, "", parser)
        }
    }
    
    static let codeRegex = try? NSRegularExpression(pattern: "```.+```", options: .dotMatchesLineSeparators)
}
