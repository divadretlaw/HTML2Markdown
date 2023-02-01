//
//  HTMLText.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation

final class HTMLText: Content {
    private(set) var text = ""
    
    func accept(_ tokenType: TokenType) throws -> Bool {
        switch tokenType {
        case .closingTagStart,
             .openingTagStart:
            return false
        case let .autoClosingTagEnd(text),
             let .equalsSign(text),
             let .quote(text),
             let .tagEnd(text),
             let .text(text),
             let .whitespace(text):
            self.text += text
            return true
        case .endOfFile:
            return true
        }
    }
}
