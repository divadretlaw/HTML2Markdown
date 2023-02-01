//
//  HTMLElement.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation

final class HTMLElement: Content {
    enum Error: Swift.Error {
        case unexpected(tokenType: TokenType)
        case mismatchedOpeningClosingTags(openingTagName: String, closingTagName: String)
        case unknown
    }
    
    enum ElementContent {
        private static let noContentTags = ["br"]
        
        // this is a root element - it has no tag, but can have children
        case root(children: [Content])
        
        // received < waiting for a tag name
        case opening
        // received < and the tag name
        case openingWithName(tagName: String, attributes: [String: String])
        // received <, the tag name and a space... so perhaps an attribute name is coming
        case openingWithNameAndMaybeAttribute(tagName: String, attributes: [String: String])
        // recieved <TAGNAME_ATTRIBUTENAME
        case openingWithNameAttributeName(tagName: String, attributes: [String: String], attributeName: String)
        // received <TAGNAME_ATTRIBUTENAME=
        case openingWithNameAttributeNameEquals(tagName: String, attributes: [String: String], attributeName: String)
        // received <TAGNAME_ATTRIBUTENAME='
        case openingWithNameAttributeNameEqualsQuote(tagName: String, attributes: [String: String], attributeName: String, attributeValue: String, quote: TokenType)
        
        case opened(tagName: String, attributes: [String: String], children: [Content])
        
        case closing(tagName: String, attributes: [String: String], children: [Content])
        case closingWithName(openingTagName: String, closingTagName: String, attributes: [String: String], children: [Content])
        case closed(tagName: String, attributes: [String: String], children: [Content])
        
        func accept(_ tokenType: TokenType) throws -> Self? {
            switch (self, tokenType) {
            case let (.root(children), .openingTagStart):
                // offer to children first
                if try offerToLatestChild(children: children, tokenType: tokenType) {
                    return self
                }
                // children aren't interested, so make a new child element
                let newChildren = try makeNewElementChild(children: children, tokenType: tokenType)
                return .root(children: newChildren)
            case let (.root(children), .endOfFile):
                // offer to children first
                if try offerToLatestChild(children: children, tokenType: tokenType) {
                    return self
                }
                // children aren't interested, so parsing is finished
                return self
            case let (.root(children), _):
                // offer to children first
                if try offerToLatestChild(children: children, tokenType: tokenType) {
                    return self
                }
                // children aren't interested, so make a new text child, and treat this
                // token as if it were text
                let newChildren = try makeNewTextChild(children: children, tokenType: tokenType)
                return .root(children: newChildren)
                
            case (.opening, .autoClosingTagEnd),
                 (.opening, .closingTagStart),
                 (.opening, .endOfFile),
                 (.opening, .equalsSign),
                 (.opening, .openingTagStart),
                 (.opening, .quote),
                 (.opening, .tagEnd):
                throw Error.unexpected(tokenType: tokenType)
            case (.opening, .whitespace):
                // ignore whitespace
                return self
            case let (.opening, .text(text)):
                // this is the opening tag name
                return .openingWithName(tagName: text, attributes: [:])
                
            case (.openingWithName, .closingTagStart),
                 (.openingWithName, .endOfFile),
                 (.openingWithName, .equalsSign),
                 (.openingWithName, .openingTagStart),
                 (.openingWithName, .quote):
                throw Error.unexpected(tokenType: tokenType)
            case let (.openingWithName(tagName, attributes), .tagEnd):
                // the end of the opening tag
                if Self.noContentTags.contains(tagName) {
                    return .closed(tagName: tagName, attributes: attributes, children: [])
                }
                return .opened(tagName: tagName, attributes: attributes, children: [])
            case let (.openingWithName(tagName, attributes), .autoClosingTagEnd):
                // the end of the element
                return .closed(tagName: tagName, attributes: attributes, children: [])
            case let (.openingWithName(tagName, attributes), .whitespace):
                // we have a name and now a space... so perhaps there's an attribute coming next?
                return .openingWithNameAndMaybeAttribute(tagName: tagName, attributes: attributes)
            case let (.openingWithName(tagName, attributes), .text(text)):
                // adding more to the tag name
                return .openingWithName(tagName: tagName + text, attributes: attributes)
                
            case (.openingWithNameAndMaybeAttribute, .closingTagStart),
                 (.openingWithNameAndMaybeAttribute, .endOfFile),
                 (.openingWithNameAndMaybeAttribute, .equalsSign),
                 (.openingWithNameAndMaybeAttribute, .openingTagStart),
                 (.openingWithNameAndMaybeAttribute, .quote):
                throw Error.unexpected(tokenType: tokenType)
            case let (.openingWithNameAndMaybeAttribute(tagName, attributes), .tagEnd):
                // the end of the opening tag
                if Self.noContentTags.contains(tagName) {
                    return .closed(tagName: tagName, attributes: attributes, children: [])
                }
                return .opened(tagName: tagName, attributes: attributes, children: [])
            case let (.openingWithNameAndMaybeAttribute(tagName, attributes), .autoClosingTagEnd):
                return .closed(tagName: tagName, attributes: attributes, children: [])
            case (.openingWithNameAndMaybeAttribute, .whitespace):
                return self
            case let (.openingWithNameAndMaybeAttribute(tagName, attributes), .text(text)):
                return .openingWithNameAttributeName(tagName: tagName, attributes: attributes, attributeName: text)
                
            case (.openingWithNameAttributeName, .autoClosingTagEnd),
                 (.openingWithNameAttributeName, .closingTagStart),
                 (.openingWithNameAttributeName, .endOfFile),
                 (.openingWithNameAttributeName, .openingTagStart),
                 (.openingWithNameAttributeName, .quote),
                 (.openingWithNameAttributeName, .tagEnd):
                throw Error.unexpected(tokenType: tokenType)
            case let (.openingWithNameAttributeName(tagName, attributes, attributeName), .equalsSign):
                return .openingWithNameAttributeNameEquals(tagName: tagName, attributes: attributes, attributeName: attributeName)
            case (.openingWithNameAttributeName, .whitespace):
                return self
            case let (.openingWithNameAttributeName(tagName, attributes, attributeName), .text(text)):
                return .openingWithNameAttributeName(tagName: tagName, attributes: attributes, attributeName: attributeName + text)
                
            // openingWithNameAttributeNameEquals: expecting a quote to start the attribute value; ignores whitespace
            case (.openingWithNameAttributeNameEquals, .autoClosingTagEnd),
                 (.openingWithNameAttributeNameEquals, .closingTagStart),
                 (.openingWithNameAttributeNameEquals, .endOfFile),
                 (.openingWithNameAttributeNameEquals, .equalsSign),
                 (.openingWithNameAttributeNameEquals, .openingTagStart),
                 (.openingWithNameAttributeNameEquals, .tagEnd),
                 (.openingWithNameAttributeNameEquals, .text):
                throw Error.unexpected(tokenType: tokenType)
            case let (.openingWithNameAttributeNameEquals(tagName, attributes, attributeName), .quote):
                return .openingWithNameAttributeNameEqualsQuote(tagName: tagName, attributes: attributes, attributeName: attributeName, attributeValue: "", quote: tokenType)
            case (.openingWithNameAttributeNameEquals, .whitespace):
                return self
                
            // openingWithNameAttributeNameEqualsQuote: expecting the attribute value or a closing quote
            case (.openingWithNameAttributeNameEqualsQuote, .endOfFile):
                throw Error.unexpected(tokenType: tokenType)
            case let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .autoClosingTagEnd(text)),
                 let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .closingTagStart(text)),
                 let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .equalsSign(text)),
                 let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .openingTagStart(text)),
                 let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .tagEnd(text)),
                 let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .text(text)),
                 let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .whitespace(text)):
                return .openingWithNameAttributeNameEqualsQuote(tagName: tagName, attributes: attributes, attributeName: attributeName, attributeValue: attributeValue + text, quote: quote)
            case let (.openingWithNameAttributeNameEqualsQuote(tagName, attributes, attributeName, attributeValue, quote), .quote(text)):
                if quote == tokenType {
                    // this quote token matches the quote that opened the attribute value - so this is the end of the value
                    var attributes = attributes
                    attributes[attributeName] = attributeValue
                    return .openingWithName(tagName: tagName, attributes: attributes)
                }
                // this quote doesn't match the quote that opened the attribute value - so treat it as text
                return .openingWithNameAttributeNameEqualsQuote(tagName: tagName, attributes: attributes, attributeName: attributeName, attributeValue: attributeValue + text, quote: quote)
                
            case (.opened, .endOfFile):
                throw Error.unexpected(tokenType: tokenType)
            case let (.opened(tagName, attributes, children), .openingTagStart):
                // offer to children first
                if try offerToLatestChild(children: children, tokenType: tokenType) {
                    return self
                }
                // children aren't interested, so make a new child element
                let newChildren = try makeNewElementChild(children: children, tokenType: tokenType)
                return .opened(tagName: tagName, attributes: attributes, children: newChildren)
            case let (.opened(tagName, attributes, children), .closingTagStart):
                // offer to children first
                if try offerToLatestChild(children: children, tokenType: tokenType) {
                    return self
                }
                // children aren't interested, start closing our element
                return .closing(tagName: tagName, attributes: attributes, children: children)
            case let (.opened(tagName, attributes, children), _):
                // offer to children first
                if try offerToLatestChild(children: children, tokenType: tokenType) {
                    return self
                }
                // children aren't interested, so make a new text child, and treat this
                // token as if it were text
                let newChildren = try makeNewTextChild(children: children, tokenType: tokenType)
                return .opened(tagName: tagName, attributes: attributes, children: newChildren)
                
            case (.closing, .autoClosingTagEnd),
                 (.closing, .closingTagStart),
                 (.closing, .endOfFile),
                 (.closing, .equalsSign),
                 (.closing, .openingTagStart),
                 (.closing, .quote),
                 (.closing, .tagEnd):
                throw Error.unexpected(tokenType: tokenType)
            case (.closing, .whitespace):
                // chomp the whitespace
                return self
            case let (.closing(tagName, attributes, children), .text(text)):
                // this is the start of the closing tag name
                return .closingWithName(openingTagName: tagName, closingTagName: text, attributes: attributes, children: children)
                
            case (.closingWithName, .autoClosingTagEnd),
                 (.closingWithName, .closingTagStart),
                 (.closingWithName, .endOfFile),
                 (.closingWithName, .equalsSign),
                 (.closingWithName, .openingTagStart),
                 (.closingWithName, .quote):
                throw Error.unexpected(tokenType: tokenType)
            case let (.closingWithName(openingTagName, closingTagName, attributes, children), .tagEnd):
                guard openingTagName.lowercased() == closingTagName.lowercased() else {
                    throw Error.mismatchedOpeningClosingTags(openingTagName: openingTagName, closingTagName: closingTagName)
                }
                return .closed(tagName: openingTagName, attributes: attributes, children: children)
            case (.closingWithName, .whitespace):
                // chomp the whitespace
                return self
            case let (.closingWithName(openingTagName, closingTagName, attributes, children), .text(text)):
                // this is the more of the closing tag name
                return .closingWithName(openingTagName: openingTagName, closingTagName: closingTagName + text, attributes: attributes, children: children)
                
            case (.closed, .endOfFile):
                return self
            case (.closed, _):
                // we are closed, so can't accept any new tokens
                return nil
            }
        }
        
        private func offerToLatestChild(children: [Content], tokenType: TokenType) throws -> Bool {
            if let lastChild = children.last,
               try lastChild.accept(tokenType) {
                return true
            }
            
            return false
        }
        
        private func makeNewElementChild(children: [Content], tokenType: TokenType) throws -> [Content] {
            var children = children
            let newChild = try HTMLElement(openingTagStart: tokenType)
            children.append(newChild)
            return children
        }
        
        private func makeNewTextChild(children: [Content], tokenType: TokenType) throws -> [Content] {
            var children = children
            let newChild = HTMLText()
            _ = try newChild.accept(tokenType)
            children.append(newChild)
            return children
        }
    }
    
    var content: ElementContent
    
    init() {
        self.content = .root(children: [])
    }
    
    private init(openingTagStart: TokenType) throws {
        switch openingTagStart {
        case .openingTagStart:
            self.content = .opening
        case .autoClosingTagEnd,
             .closingTagStart,
             .endOfFile,
             .equalsSign,
             .quote,
             .tagEnd,
             .text,
             .whitespace:
            throw Error.unexpected(tokenType: openingTagStart)
        }
        self.content = .opening
    }
    
    func accept(_ tokenType: TokenType) throws -> Bool {
        if let newContent = try content.accept(tokenType) {
            content = newContent
            return true
        }
        
        return false
    }
}
