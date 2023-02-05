//
//  HTMLParser.swift
//  HTML2Markdown
//
//  Created by Matthew Flint on 2021-12-07.
//

import Foundation
import SwiftSoup

public struct HTMLParser {
    let baseUri: String
    let parser: Parser
    
    public init(baseUri: String = "", parser: Parser = Parser.htmlParser()) {
        self.baseUri = baseUri
        self.parser = parser
    }
    
    public func parse(html: String) throws -> Node {
        let document = try SwiftSoup.parse(html, baseUri, parser)
        return document
    }
}
