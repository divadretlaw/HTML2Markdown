//
//  Tokenizer.swift
//  HTML2Markdown
//
//  Created by Matthew Flint on 2021-12-05.
//

import Foundation

struct Tokenizer {
    private static var allTokens: [Token] {
        [
            TagStartToken(),
            TagEndToken(),
            AutoclosingTagEndToken(),
            EqualSignToken(),
            QuoteToken(),
            WhitespaceToken(),
            TextToken()
        ]
    }
    
    enum Error: Swift.Error {
        case unclaimed(String)
    }
    
    func tokenize(html: String) throws -> [TokenType] {
        var result = [TokenType]()
        
        let scanner = Scanner(string: html)
        scanner.charactersToBeSkipped = nil
        
        while !scanner.isAtEnd {
            var claimed = false
            
            for token in Self.allTokens {
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
        
        result.append(.endOfFile)
        
        return result
    }
}

enum TokenType: Equatable {
    case openingTagStart(String)
    case closingTagStart(String)
    case tagEnd(String)
    case autoClosingTagEnd(String)
    case equalsSign(String)
    case quote(String)
    case whitespace(String)
    case text(String)
    case endOfFile
}

private protocol Token {
    func accept(scanner: Scanner) -> TokenType?
}

private struct TagStartToken: Token {
    func accept(scanner: Scanner) -> TokenType? {
        var scanned = ""
        
        guard let openingBracket = scanner.scanString("<") else {
            return nil
        }
        
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
}

private struct TagEndToken: Token {
    func accept(scanner: Scanner) -> TokenType? {
        guard let closingBracket = scanner.scanString(">") else {
            return nil
        }
        return .tagEnd(closingBracket)
    }
}

private struct AutoclosingTagEndToken: Token {
    func accept(scanner: Scanner) -> TokenType? {
        let fallbackIndex = scanner.currentIndex
        var scanned = ""
        
        guard let slash = scanner.scanString("/") else {
            return nil
        }
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
}

private struct EqualSignToken: Token {
    func accept(scanner: Scanner) -> TokenType? {
        guard let equals = scanner.scanString("=") else {
            return nil
        }
        return .equalsSign(equals)
    }
}

private struct QuoteToken: Token {
    func accept(scanner: Scanner) -> TokenType? {
        guard let quote = scanner.scanString("'") ?? scanner.scanString("\"") else {
            return nil
        }
        return .quote(quote)
    }
}

private struct WhitespaceToken: Token {
    private let characterSet = CharacterSet.whitespacesAndNewlines

    func accept(scanner: Scanner) -> TokenType? {
        guard let whitespace = scanner.scanCharacters(from: characterSet) else {
            return nil
        }
        return .whitespace(whitespace)
    }
}

private extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains(_:))
    }
}

private struct TextToken: Token {
    private let delimiters = CharacterSet(charactersIn: "<>/='\"").union(.whitespacesAndNewlines)
    private let allowedFirstCharacter = CharacterSet(charactersIn: "<>'=\"").union(.whitespacesAndNewlines).inverted
    
    func accept(scanner: Scanner) -> TokenType? {
        let fallbackIndex = scanner.currentIndex
        
        guard let firstCharacter = scanner.scanCharacter(),
              allowedFirstCharacter.containsUnicodeScalars(of: firstCharacter) else {
            // failed - so rewind
            scanner.currentIndex = fallbackIndex
            return nil
        }
        
        var scanned = String(firstCharacter)
        
        if let more = scanner.scanUpToCharacters(from: delimiters) {
            scanned += more
        }
        
        return .text(scanned.entityDecoded())
    }
}
