//
//  Content.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation

protocol Content {
    func accept(_ tokenType: TokenType) throws -> Bool
}

extension Content {
    func result() throws -> Element {
        if let text = self as? HTMLText {
            return .text(text: text.text)
        }
        
        if let element = self as? HTMLElement {
            switch element.content {
            case let .root(children):
                let elements = children.compactMap { try? $0.result() }
                return .root(children: elements)
            case let .closed(tagName, attributes, children):
                let elements = children.compactMap { try? $0.result() }
                let tag = Tag(name: tagName, attributes: attributes)
                return .element(tag: tag, children: elements)
            default:
                throw HTMLElement.Error.unknown
            }
        }
        
        throw HTMLElement.Error.unknown
    }
}
