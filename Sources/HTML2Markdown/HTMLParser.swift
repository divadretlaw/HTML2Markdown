//
//  HTMLParser.swift
//  HTML2Markdown
//
//  Created by Matthew Flint on 2021-12-07.
//

import Foundation

public struct HTMLParser {
    let tokenizer: Tokenizer
    
    public init() {
        self.tokenizer = Tokenizer()
    }
    
    public func parse(html: String) throws -> Element {
        let tokens = try tokenizer.tokenize(html: html)
        return try parse(tokens: tokens)
    }
    
    func parse(tokens: [TokenType]) throws -> Element {
        let root = HTMLElement()
        
        for token in tokens {
            if try root.accept(token) == false {
                continue
            }
        }
        
        return try root.result()
    }
}
