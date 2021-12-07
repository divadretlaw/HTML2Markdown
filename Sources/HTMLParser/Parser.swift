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
		case root(children: [Content])

		case opening
		case openingWithName(tagName: String)
		case opened(tagName: String, children: [Content])

		case closing(tagName: String, children: [Content])
		case closingWithName(openingTagName: String, closingTagName: String, children: [Content])
		case closed(tagName: String, children: [Content])

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
				return .openingWithName(tagName: text)

			case (.openingWithName, .openingTagStart),
				(.openingWithName, .closingTagStart),
				(.openingWithName, .equalsSign),
				(.openingWithName, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.openingWithName(let tagName), .tagEnd):
				// the end of the opening tag
				return .opened(tagName: tagName, children: [])
			case (.openingWithName(let tagName), .autoClosingTagEnd):
				// the end of the element
				return .closed(tagName: tagName, children: [])
			case (.openingWithName, .whitespace):
				// ignore whitespace
				return self
			case (.openingWithName(let tagName), .text(let text)):
				// adding more to the tag name
				return .openingWithName(tagName: tagName + text)

			case (.opened(let tagName, let children), .openingTagStart):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, so make a new child element
				let newChildren = try self.makeNewElementChild(children: children, tokenType: tokenType)
				return .opened(tagName: tagName, children: newChildren)
			case (.opened(let tagName, let children), .closingTagStart):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, start closing our element
				return .closing(tagName: tagName, children: children)
			case (.opened(let tagName, let children), _):
				// offer to children first
				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
					return self
				}
				// children aren't interested, so make a new text child, and treat this
				// token as if it were text
				let newChildren = try self.makeNewTextChild(children: children, tokenType: tokenType)
				return .opened(tagName: tagName, children: newChildren)

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
			case (.closing(let tagName, let children), .text(let text)):
				// this is the start of the closing tag name
				return .closingWithName(openingTagName: tagName, closingTagName: text, children: children)

			case (.closingWithName, .openingTagStart),
				(.closingWithName, .closingTagStart),
				(.closingWithName, .autoClosingTagEnd),
				(.closingWithName, .equalsSign),
				(.closingWithName, .quote):
				throw Error.unexpected(tokenType: tokenType)
			case (.closingWithName(let openingTagName, let closingTagName, let children), .tagEnd):
				guard openingTagName == closingTagName else {
					throw Error.mismatchedOpeningClosingTags(openingTagName: openingTagName, closingTagName: closingTagName)
				}
				return .closed(tagName: openingTagName, children: children)
			case (.closingWithName, .whitespace):
				// chomp the whitespace
				return self
			case (.closingWithName(let openingTagName, let closingTagName, let children), .text(let text)):
				// this is the more of the closing tag name
				return .closingWithName(openingTagName: openingTagName, closingTagName: closingTagName + text, children: children)

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




//			switch tokenType {
//			case .openingTagStart:
//				return try handleOpeningTagStart(tokenType: tokenType)
//			case .closingTagStart:
//				return try handleClosingTagStart(tokenType: tokenType)
//			case .tagEnd:
//				return try handleTagEnd(tokenType: tokenType)
//			case .autoClosingTagEnd:
//				return try handleAutoClosingTagEnd(tokenType: tokenType)
//			case .equalsSign:
//				return try handleEqualsSign(tokenType: tokenType)
//			case .quote:
//				return try handleQuote(tokenType: tokenType)
//			case .whitespace:
//				return try handleWhitespace(tokenType: tokenType)
//			case .text(let text):
//				return try handleText(text)
//			}
		}

		// <
//		private func handleOpeningTagStart(tokenType: TokenType) throws -> Self? {
//			switch self {
//			case .root(let children):
//				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
//					return self
//				}
//				let newChildren = try self.makeNewChild(children: children, tokenType: tokenType)
//				return .root(children: children)
//			case .opened(let children):
//				if try self.offerToLatestChild(children: children, tokenType: tokenType) {
//					return self
//				}
//				let newChildren = try self.makeNewChild(children: children, tokenType: tokenType)
//				return .opened(children: children)
//			case .opening,
//					.openingWithName,
//					.closing,
//					.closingWithMatchingName:
//				// if we're already opening or closing a tag, then another opening tag is illegal
//				throw Error.unexpected(tokenType)
//			case .closed:
//				return nil
//			}
//		}

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

//		// </
//		private func handleClosingTagStart(tokenType: TokenType) throws -> Self? {
//			switch self {
//			case .root(let children),
//					.opened(let children):
//				if let lastChild = children.last,
//				   try lastChild.accept(tokenType) {
//					return self
//				}
//
//				// last child didn't accept the token - so give it to a new child
//				var children = children
//				let newChild = Text()
//				_ = try newChild.accept(tokenType)
//				children.append(newChild)
//				return .root(children: children)
//			case .opening,
//					.openingWithName,
//					.closing,
//					.closingWithMatchingName:
//				throw Error.unexpected(tokenType)
//			case .closed:
//				return nil
//			}
//		}
//
//		// >
//		private func handleTagEnd(tokenType: TokenType) throws -> Self? {
//			switch self {
//			case .root(let children),
//					.opened(let children):
//				<#code#>
//			case .opening:
//				<#code#>
//			case .openingWithName(let name):
//				<#code#>
//			case .opened(let children):
//				<#code#>
//			case .closing(let children):
//				<#code#>
//			case .closingWithMatchingName(let children):
//				<#code#>
//			case .closed(let children):
//				<#code#>
//			}
//		}
//
//		private func handleAutoClosingTagEnd(tokenType: TokenType) throws -> Self? {
//			preconditionFailure()
//		}
//
//		private func handleEqualsSign(tokenType: TokenType) throws -> Self? {
//			preconditionFailure()
//		}
//
//		private func handleQuote(tokenType: TokenType) throws -> Self? {
//			preconditionFailure()
//		}
//
//		private func handleWhitespace(tokenType: TokenType) throws -> Self? {
//			preconditionFailure()
//		}
//
//		private func handleText(_ text: String) throws -> Self? {
//			preconditionFailure()
//		}
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
