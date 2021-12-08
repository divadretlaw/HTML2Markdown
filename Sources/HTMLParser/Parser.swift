//
//  Parser.swift
//  
//
//  Created by Matthew Flint on 2021-12-07.
//

import Foundation

protocol Content {
	func accept(_ tokenType: TokenType) throws -> Bool
}

final class Text: Content {
	public private(set) var text: String = ""

	func accept(_ tokenType: TokenType) throws -> Bool {
		switch tokenType {
		case .closingTagStart,
				.openingTagStart:
			return false
		case .tagEnd(let text),
				.autoClosingTagEnd(let text),
				.equalsSign(let text),
				.quote(let text),
				.whitespace(let text),
				.text(let text):
			self.text += text
			return true
		}
	}
}

final class Element: Content {
	enum Error: Swift.Error {
		case unexpected(tokenType: TokenType)
		case mismatchedOpeningClosingTags(openingTagName: String, closingTagName: String)
	}

	enum ElementContent {
		// this is a root element - it has no tag, but can have children
		case root(children: [Content])

		// received < waiting for a tag name
		case opening
		// received < and the tag name
		case openingWithName(tagName: String, attributes: [String : String])
		// received <, the tag name and a space... so perhaps an attribute name is coming
		case openingWithNameAndMaybeAttribute(tagName: String, attributes: [String : String])
		// recieved <TAGNAME_ATTRIBUTENAME
		case openingWithNameAttributeName(tagName: String, attributes: [String : String], attributeName: String)
		// received <TAGNAME_ATTRIBUTENAME=
		case openingWithNameAttributeNameEquals(tagName: String, attributes: [String : String], attributeName: String)
		// received <TAGNAME_ATTRIBUTENAME='
		case openingWithNameAttributeNameEqualsQuote(tagName: String, attributes: [String : String], attributeName: String, attributeValue: String, quote: TokenType)

		case opened(tagName: String, attributes: [String : String], children: [Content])

		case closing(tagName: String, attributes: [String : String], children: [Content])
		case closingWithName(openingTagName: String, closingTagName: String, attributes: [String : String], children: [Content])
		case closed(tagName: String, attributes: [String : String], children: [Content])

		func accept(_ tokenType: TokenType) throws -> Self? {
			switch (self, tokenType) {
			case (.root(let children), .openingTagStart):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, so make a new child element
				let newChildren = try self.makeNewElementChild(children: children, tokenType: tokenType)
				return .root(children: newChildren)
			case (.root(let children), _):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, so make a new text child, and treat this
				// token as if it were text
				let newChildren = try self.makeNewTextChild(children: children, tokenType: tokenType)
				return .root(children: newChildren)

			case (.opening, .openingTagStart),
				(.opening, .closingTagStart),
				(.opening, .tagEnd),
				(.opening, .autoClosingTagEnd),
				(.opening, .equalsSign),
				(.opening, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.opening, .whitespace):
				// ignore whitespace
				return self
			case (.opening, .text(let text)):
				// this is the opening tag name
				return .openingWithName(tagName: text, attributes: [:])

			case (.openingWithName, .openingTagStart),
				(.openingWithName, .closingTagStart),
				(.openingWithName, .equalsSign),
				(.openingWithName, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.openingWithName(let tagName, let attributes), .tagEnd):
				// the end of the opening tag
				return .opened(tagName: tagName, attributes: attributes, children: [])
			case (.openingWithName(let tagName, let attributes), .autoClosingTagEnd):
				// the end of the element
				return .closed(tagName: tagName, attributes: attributes, children: [])
			case (.openingWithName(let tagName, let attributes), .whitespace):
				// we have a name and now a space... so perhaps there's an attribute coming next?
				return .openingWithNameAndMaybeAttribute(tagName: tagName, attributes: attributes)
			case (.openingWithName(let tagName, let attributes), .text(let text)):
				// adding more to the tag name
				return .openingWithName(tagName: tagName + text, attributes: attributes)

			case (.openingWithNameAndMaybeAttribute, .openingTagStart),
				(.openingWithNameAndMaybeAttribute, .closingTagStart),
				(.openingWithNameAndMaybeAttribute, .equalsSign),
				(.openingWithNameAndMaybeAttribute, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.openingWithNameAndMaybeAttribute(let tagName, let attributes), .tagEnd):
				return .opened(tagName: tagName, attributes: attributes, children: [])
			case (.openingWithNameAndMaybeAttribute(let tagName, let attributes), .autoClosingTagEnd):
				return .closed(tagName: tagName, attributes: attributes, children: [])
			case (.openingWithNameAndMaybeAttribute, .whitespace):
				return self
			case (.openingWithNameAndMaybeAttribute(let tagName, let attributes), .text(let text)):
				return .openingWithNameAttributeName(tagName: tagName, attributes: attributes, attributeName: text)

			case (.openingWithNameAttributeName, .openingTagStart),
				(.openingWithNameAttributeName, .closingTagStart),
				(.openingWithNameAttributeName, .tagEnd),
				(.openingWithNameAttributeName, .autoClosingTagEnd),
				(.openingWithNameAttributeName, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.openingWithNameAttributeName(let tagName, let attributes, let attributeName), .equalsSign):
				return .openingWithNameAttributeNameEquals(tagName: tagName, attributes: attributes, attributeName: attributeName)
			case (.openingWithNameAttributeName, .whitespace):
				return self
			case (.openingWithNameAttributeName(let tagName, let attributes, let attributeName), .text(let text)):
				return .openingWithNameAttributeName(tagName: tagName, attributes: attributes, attributeName: attributeName + text)

			// openingWithNameAttributeNameEquals: expecting a quote to start the attribute value; ignores whitespace
			case (.openingWithNameAttributeNameEquals, .openingTagStart),
				(.openingWithNameAttributeNameEquals, .closingTagStart),
				(.openingWithNameAttributeNameEquals, .tagEnd),
				(.openingWithNameAttributeNameEquals, .autoClosingTagEnd),
				(.openingWithNameAttributeNameEquals, .equalsSign),
				(.openingWithNameAttributeNameEquals, .text):
				throw Error.unexpected(tokenType: tokenType)
			case (.openingWithNameAttributeNameEquals(let tagName, let attributes, let attributeName), .quote):
				return .openingWithNameAttributeNameEqualsQuote(tagName: tagName, attributes: attributes, attributeName: attributeName, attributeValue: "", quote: tokenType)
			case (.openingWithNameAttributeNameEquals, .whitespace):
				return self

			// openingWithNameAttributeNameEqualsQuote: expecting the attribute value or a closing quote
			case (.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .openingTagStart(let text)),
				(.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .closingTagStart(let text)),
				(.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .tagEnd(let text)),
				(.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .autoClosingTagEnd(let text)),
				(.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .equalsSign(let text)),
				(.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .whitespace(let text)),
				(.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .text(let text)):
				return .openingWithNameAttributeNameEqualsQuote(tagName: tagName, attributes: attributes, attributeName: attributeName, attributeValue: attributeValue + text, quote: quote)
			case (.openingWithNameAttributeNameEqualsQuote(let tagName, let attributes, let attributeName, let attributeValue, let quote), .quote(let text)):
				if quote == tokenType {
					// this quote token matches the quote that opened the attribute value - so this is the end of the value
					var attributes = attributes
					attributes[attributeName] = attributeValue
					return .openingWithName(tagName: tagName, attributes: attributes)
				}
				// this quote doesn't match the quote that opened the attribute value - so treat it as text
				return .openingWithNameAttributeNameEqualsQuote(tagName: tagName, attributes: attributes, attributeName: attributeName, attributeValue: attributeValue + text, quote: quote)

			case (.opened(let tagName, let attributes, let children), .openingTagStart):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, so make a new child element
				let newChildren = try self.makeNewElementChild(children: children, tokenType: tokenType)
				return .opened(tagName: tagName, attributes: attributes, children: newChildren)
			case (.opened(let tagName, let attributes, let children), .closingTagStart):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, start closing our element
				return .closing(tagName: tagName, attributes: attributes, children: children)
			case (.opened(let tagName, let attributes, let children), _):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, so make a new text child, and treat this
				// token as if it were text
				let newChildren = try self.makeNewTextChild(children: children, tokenType: tokenType)
				return .opened(tagName: tagName, attributes: attributes, children: newChildren)

			case (.closing, .openingTagStart),
				(.closing, .closingTagStart),
				(.closing, .tagEnd),
				(.closing, .autoClosingTagEnd),
				(.closing, .equalsSign),
				(.closing, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.closing, .whitespace):
				// chomp the whitespace
				return self
			case (.closing(let tagName, let attributes, let children), .text(let text)):
				// this is the start of the closing tag name
				return .closingWithName(openingTagName: tagName, closingTagName: text, attributes: attributes, children: children)

			case (.closingWithName, .openingTagStart),
				(.closingWithName, .closingTagStart),
				(.closingWithName, .autoClosingTagEnd),
				(.closingWithName, .equalsSign),
				(.closingWithName, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.closingWithName(let openingTagName, let closingTagName, let attributes, let children), .tagEnd):
				guard openingTagName == closingTagName else {
					throw Error.mismatchedOpeningClosingTags(openingTagName: openingTagName, closingTagName: closingTagName)
				}
				return .closed(tagName: openingTagName, attributes: attributes, children: children)
			case (.closingWithName, .whitespace):
				// chomp the whitespace
				return self
			case (.closingWithName(let openingTagName, let closingTagName, let attributes, let children), .text(let text)):
				// this is the more of the closing tag name
				return .closingWithName(openingTagName: openingTagName, closingTagName: closingTagName + text, attributes: attributes, children: children)

			case (.closed, _):
				// we are closed, so can't accept any new tokens
				return nil
			}


			// openingTagStart
			// closingTagStart
			// tagEnd
			// autoClosingTagEnd
			// equalsSign
			// quote
			// whitespace
			// text
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
			let newChild = try Element(openingTagStart: tokenType)
			children.append(newChild)
			return children
		}

		private func makeNewTextChild(children: [Content], tokenType: TokenType) throws -> [Content] {
			var children = children
			let newChild = Text()
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
		case .closingTagStart,
				.tagEnd,
				.autoClosingTagEnd,
				.equalsSign,
				.quote,
				.whitespace,
				.text:
			throw Error.unexpected(tokenType: openingTagStart)
		}
		self.content = .opening
	}

	func accept(_ tokenType: TokenType) throws -> Bool {
		if let newContent = try self.content.accept(tokenType) {
			self.content = newContent
			return true
		}

		return false
	}
}


// some <strong>fancy</strong> words

//	root
//		text(some )
//		element(strong)
//			text(fancy)
//		text( words)

// <p>some fancy words</p>

//	root
//		element(p)
//			text(some fancy words)

struct Parser {
	func parse(tokens: [TokenType]) throws -> Element {
		let root = Element()

		for token in tokens {
			if try root.accept(token) == false {
				// TODO: throw error if a token can't be handed by anything?
				preconditionFailure()
			}
		}

		return root
	}
}
