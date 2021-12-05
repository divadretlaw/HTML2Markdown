//
//  Tokenizer.swift
//  
//
//  Created by Matthew Flint on 2021-12-05.
//

import Foundation

enum TokenType: Equatable {
	case openingTagStart
	case closingTagStart
	case tagEnd
	case autoClosingTagEnd
	case equalsSign
	case whitespace
	case quote(String)
	case text(String)
}

private protocol Token: AnyObject {
	var tokenType: TokenType { get }

	init?(character: Character)

	func accept(character: Character) -> Bool
}

private enum AllTokens {
	static let types: [Token.Type] = [
		TagStartToken.self,
		TagEndToken.self,
		AutoclosingTagEndToken.self,
		EqualSignToken.self,
		WhitespaceToken.self,
		QuoteToken.self,
		TextToken.self,
	]
}

private class TagStartToken: Token {
	var tokenType: TokenType = .openingTagStart

	required init?(character: Character) {
		guard character == "<" else {
			return nil
		}
	}

	func accept(character: Character) -> Bool {
		if character.isWhitespace {
			return true
		}

		// TODO: check we're not already .closingTagStart
		if character == "/" {
			self.tokenType = .closingTagStart
			return true
		}

		return false
	}
}

private class TagEndToken: Token {
	let tokenType: TokenType = .tagEnd

	required init?(character: Character) {
		guard character == ">" else {
			return nil
		}
	}

	func accept(character: Character) -> Bool {
		false
	}
}

private class AutoclosingTagEndToken: Token {
	var tokenType: TokenType {
		if let delegateToToken = delegateToToken {
			return delegateToToken.tokenType
		}

		if !complete {
			return .text(self.text)
		}

		return .autoClosingTagEnd
	}

	private var text: String
	private var otherCharacters = [Character]()
	private var complete = false
	private var delegateToToken: Token?

	required init?(character: Character) {
		guard character == "/" else {
			return nil
		}
		text = character.description
	}

	func accept(character: Character) -> Bool {
		if let delegateToToken = delegateToToken {
			return delegateToToken.accept(character: character)
		}

		if complete {
			// don't accept any more
			return false
		}

		self.text += character.description

		if character.isWhitespace {
			otherCharacters.append(character)
			return true
		}

		if character == ">" {
			complete = true
			return true
		}

		// unexpected character - so this isn't the end of a tag
		guard let delegateToToken = TextToken(character: "/") else {
			return false
		}

		self.delegateToToken = delegateToToken
		for otherCharacter in otherCharacters {
			_ = delegateToToken.accept(character: otherCharacter)
		}
		return delegateToToken.accept(character: character)
	}
}

private class EqualSignToken: Token {
	let tokenType: TokenType = .equalsSign

	required init?(character: Character) {
		guard character == "=" else {
			return nil
		}
	}

	func accept(character: Character) -> Bool {
		false
	}
}

private class WhitespaceToken: Token {
	let tokenType: TokenType = .whitespace

	required init?(character: Character) {
		guard character.isWhitespace else {
			return nil
		}
	}

	func accept(character: Character) -> Bool {
		character.isWhitespace
	}
}

private class QuoteToken: Token {
	var tokenType: TokenType = .quote("")

	required init?(character: Character) {
		guard character == "'" ||
			character == "\"" else {
				return nil
			}

		self.tokenType = .quote(character.description)
	}

	func accept(character: Character) -> Bool {
		false
	}
}

private class TextToken: Token {
	var tokenType: TokenType = .text("")
	private var text = ""

	required init?(character: Character) {
		text = character.description
	}

	func accept(character: Character) -> Bool {
		text += character.description
		tokenType = .text(self.text)
		return true
	}
}

struct Tokenizer {
	func tokenize(html: String) -> [TokenType] {
		var tokens = [Token]()

		var currentTokenVisitor: Token?

		for character in html {
			// offer to the current visitor first
			if let latestTokenVisitor = currentTokenVisitor,
			   latestTokenVisitor.accept(character: character) {
				// current visitor accepted this new character
			} else {
				// current visitor did not accept the new character, so find a new one
				for tokenVisitor in AllTokens.types {
					if let token = tokenVisitor.init(character: character) {
						tokens.append(token)
						currentTokenVisitor = token
						break
					}
				}
			}
		}

		return tokens.map { $0.tokenType }
	}
}
