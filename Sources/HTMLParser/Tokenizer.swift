//
//  Tokenizer.swift
//  
//
//  Created by Matthew Flint on 2021-12-05.
//

import Foundation

enum TokenType: Equatable {
	case openingTagStart(String)
	case closingTagStart(String)
	case tagEnd(String)
	case autoClosingTagEnd(String)
	case equalsSign(String)
	case quote(String)
	case whitespace(String)
	case text(String)
}

private protocol Token: AnyObject {
	init()
	func accept(scanner: Scanner) -> TokenType?
}

private class TagStartToken: Token {
	required init() {}

	func accept(scanner: Scanner) -> TokenType? {
		var scanned = ""

		if let openingBracket = scanner.scanString("<") {
			scanned += openingBracket
			let fallbackIndex = scanner.currentIndex

			// we have "<", but is there more? Start by chomping any whitespace
			if let whitespace = scanner.scanCharacters(from: .whitespacesAndNewlines) {
				scanned += whitespace
			}

			if let slash = scanner.scanString("/") {
				// there's a slash!
				scanned += slash
				return .closingTagStart(scanned)
			}

			// there's no slash, so rewind back to the fallback index
			// and just return "<"
			scanner.currentIndex = fallbackIndex
			return .openingTagStart("<")
		}

		return nil
	}
}

private class TagEndToken: Token {
	required init() {}

	func accept(scanner: Scanner) -> TokenType? {
		if let closingBracket = scanner.scanString(">") {
			return .tagEnd(closingBracket)
		}
		return nil
	}
}

private class AutoclosingTagEndToken: Token {
	required init() {}

	func accept(scanner: Scanner) -> TokenType? {
		let fallbackIndex = scanner.currentIndex
		var scanned = ""

		if let slash = scanner.scanString("/") {
			scanned += slash

			// chomp any whitespace
			if let whitespace = scanner.scanCharacters(from: .whitespacesAndNewlines) {
				scanned += whitespace
			}

			if let closingBracket = scanner.scanString(">") {
				// there's a ">"
				scanned += closingBracket
				return .autoClosingTagEnd(scanned)
			}

			// there's no ">", so rewind back to the fallback index
			// and return nothing
			scanner.currentIndex = fallbackIndex
			return nil
		}

		return nil
	}
}

private class EqualSignToken: Token {
	required init() {}

	func accept(scanner: Scanner) -> TokenType? {
		if let equals = scanner.scanString("=") {
			return .equalsSign(equals)
		}
		return nil
	}
}

private class QuoteToken: Token {
	required init() {}

	func accept(scanner: Scanner) -> TokenType? {
		if let quote = scanner.scanString("'") ??
			scanner.scanString("\"") {
			return .quote(quote)
		}
		return nil
	}
}

private class WhitespaceToken: Token {
	required init() {}

	private static let characterSet = CharacterSet.whitespacesAndNewlines

	func accept(scanner: Scanner) -> TokenType? {
		if let whitespace = scanner.scanCharacters(from: Self.characterSet) {
			return .whitespace(whitespace)
		}
		return nil
	}
}

private extension CharacterSet {
	func containsUnicodeScalars(of character: Character) -> Bool {
		return character.unicodeScalars.allSatisfy(contains(_:))
	}
}

private class TextToken: Token {
	private static let delimiters = CharacterSet(charactersIn: "<>/='\"").union(.whitespacesAndNewlines)
	private static let allowedFirstCharacter = CharacterSet(charactersIn: "<>'=\"").union(.whitespacesAndNewlines).inverted

	required init() {}

	func accept(scanner: Scanner) -> TokenType? {
		let fallbackIndex = scanner.currentIndex
		if let firstCharacter = scanner.scanCharacter(),
		   Self.allowedFirstCharacter.containsUnicodeScalars(of: firstCharacter) {
			var scanned = String(firstCharacter)

			if let more = scanner.scanUpToCharacters(from: Self.delimiters) {
				scanned += more
			}

			return .text(scanned)
		}

		// failed - so rewind
		scanner.currentIndex = fallbackIndex
		return nil
	}
}

struct Tokenizer {
	private static let tokens: [Token] = [
		TagStartToken(),
		TagEndToken(),
		AutoclosingTagEndToken(),
		EqualSignToken(),
		QuoteToken(),
		WhitespaceToken(),
		TextToken(),
	]

	enum Error: Swift.Error {
		case unclaimed(String)
	}

	func tokenize(html: String) throws -> [TokenType] {
		var result = [TokenType]()

		let scanner = Scanner(string: html)
		scanner.charactersToBeSkipped = nil

		while !scanner.isAtEnd {
			var claimed = false

			for token in Self.tokens {
				if let token = token.accept(scanner: scanner) {
					result.append(token)
					claimed = true
					break
				}
			}

			guard claimed else {
				let remaining = html[scanner.currentIndex...]
				throw Error.unclaimed(String(remaining))
			}
		}

		return result
	}
}
