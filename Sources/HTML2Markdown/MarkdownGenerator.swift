//
//  MarkdownGenerator.swift
//
//
//  Created by Matthew Flint on 2021-12-08.
//

import Foundation

public enum MarkdownGenerator {
    public struct Options: OptionSet {
        public let rawValue: Int
        
        /// Output a pretty bullet `•` instead of an asterisk, for unordered lists
        public static let unorderedListBullets = Options(rawValue: 1 << 0)
        /// Escape existing markdown syntax in order to prevent them being rendered
        public static let escapeMarkdown = Options(rawValue: 1 << 1)
        /// Try to respect Mastodon classes
        public static let mastodon = Options(rawValue: 1 << 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

public extension Element {
    struct OutputContext: OptionSet {
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        static let isSingleChildInRoot = OutputContext(rawValue: 1 << 0)
        static let isFirstChild = OutputContext(rawValue: 1 << 1)
        static let isFinalChild = OutputContext(rawValue: 1 << 2)
        static let isUnorderedList = OutputContext(rawValue: 1 << 3)
        static let isOrderedList = OutputContext(rawValue: 1 << 4)
    }
    
    func toMarkdown(options: MarkdownGenerator.Options = []) -> String {
        var markdown = toMarkdown(options: options, context: [], childIndex: 0)
        
        // we only want a maximum of two consecutive newlines
        markdown = replace(regex: "[\n]{3,}", with: "\n\n", in: markdown)
        
        return markdown
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func toMarkdown(
        options: MarkdownGenerator.Options,
        context: OutputContext,
        childIndex: Int,
        prefixPostfixBlock: ((String, String) -> Void)? = nil
    ) -> String {
        var result = ""
        
        switch self {
        case let .root(children):
            let childrenWithContent = children.filter { $0.shouldRender() }
            
            for (index, child) in childrenWithContent.enumerated() {
                var context: OutputContext = []
                if childrenWithContent.count == 1 {
                    context.insert(.isSingleChildInRoot)
                }
                if index == 0 {
                    context.insert(.isFirstChild)
                }
                if index == childrenWithContent.count - 1 {
                    context.insert(.isFinalChild)
                }
                result += child.toMarkdown(options: options, context: context, childIndex: index)
            }
        case let .element(tag, children):
            switch tag.name.lowercased() {
            case "span":
                if let classes = tag.attributes["class"]?.split(separator: " ") {
                    if options.contains(.mastodon) {
                        if classes.contains("invisible") {
                            break
                        }
                        
                        if classes.contains("ellipsis") {
                            result += output(children, options: options)
                            result += "…"
                            break
                        }
                    }
                }
                
                result += output(children, options: options)
            case "p":
                if !context.contains(.isSingleChildInRoot),
                   !context.contains(.isFirstChild) {
                    result += "\n"
                }
                
                result += output(children, options: options).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !context.contains(.isSingleChildInRoot),
                   !context.contains(.isFinalChild) {
                    result += "\n"
                }
            case "br":
                if !context.contains(.isFinalChild) {
                    result += "  \n"
                }
            // TODO: strip whitespace on the next line of text, immediately after this linebreak
            case "em":
                var prefix = ""
                var postfix = ""
                
                let blockToPass: (String, String) -> Void = {
                    prefix = $0
                    postfix = $1
                }
                
                let text = output(children, options: options, prefixPostfixBlock: blockToPass)
                
                // I'd rather use _ here, but cmark-gfm has better behaviour with *
                result += "\(prefix)*" + text + "*\(postfix)"
            case "strong":
                var prefix = ""
                var postfix = ""
                
                let blockToPass: (String, String) -> Void = {
                    prefix = $0
                    postfix = $1
                }
                
                let text = output(children, options: options, prefixPostfixBlock: blockToPass)
                
                result += "\(prefix)**" + text + "**\(postfix)"
            case "a":
                if let destination = tag.attributes["href"] {
                    result += "[\(output(children, options: options))](\(destination))"
                } else {
                    result += output(children, options: options)
                }
            case "ul":
                if !context.contains(.isFirstChild) {
                    result += "\n\n"
                }
                result += output(children, options: options, context: .isUnorderedList)
                
                if !context.contains(.isFinalChild) {
                    result += "\n\n"
                }
            case "ol":
                if !context.contains(.isFirstChild) {
                    result += "\n\n"
                }
                result += output(children, options: options, context: .isOrderedList)
                
                if !context.contains(.isFinalChild) {
                    result += "\n\n"
                }
            case "li":
                if context.contains(.isUnorderedList) {
                    let bullet = options.contains(.unorderedListBullets) ? "•" : "*"
                    result += "\(bullet) \(output(children, options: options))"
                }
                if context.contains(.isOrderedList) {
                    result += "\(childIndex + 1). \(output(children, options: options))"
                }
                if !context.contains(.isFinalChild) {
                    result += "\n"
                }
            default:
                result += output(children, options: options)
            }
        case let .text(text):
            // replace all whitespace with a single space, and escape *
            
            // Notes:
            // the first space here is an ideographic space, U+3000
            // second space is non-breaking space, U+00A0
            // third space is a regular space, U+0020
            let text = replace(regex: "[　  \t\n\r]{1,}", with: " ", in: text)
            
            if !text.isEmpty {
                if options.contains(.escapeMarkdown) {
                    result += text
                        .replacingOccurrences(of: "*", with: "\\*")
                        .replacingOccurrences(of: "[", with: "\\[")
                        .replacingOccurrences(of: "]", with: "\\]")
                        .replacingOccurrences(of: "`", with: "\\`")
                        .replacingOccurrences(of: "_", with: "\\_")
                } else {
                    result += text
                }
            }
        }
        
        return result
    }
    
    private func replace(regex pattern: String, with replacement: String, in string: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return string
        }
        
        let range = NSRange(location: 0, length: string.utf16.count)
        
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacement)
    }
    
    private func output(
        _ children: [Element],
        options: MarkdownGenerator.Options,
        context: OutputContext = [],
        prefixPostfixBlock: ((String, String) -> Void)? = nil
    ) -> String {
        var result = ""
        let childrenWithContent = children.filter { $0.shouldRender() }
        
        for (index, child) in childrenWithContent.enumerated() {
            var context = context
            if index == 0 {
                context.insert(.isFirstChild)
            }
            if index == childrenWithContent.count - 1 {
                context.insert(.isFinalChild)
            }
            result += child.toMarkdown(options: options, context: context, childIndex: index, prefixPostfixBlock: prefixPostfixBlock)
        }
        
        if let prefixPostfixBlock = prefixPostfixBlock {
            if result.hasPrefix(" "), result.hasSuffix(" ") {
                prefixPostfixBlock(" ", " ")
                result = result.trimmingCharacters(in: .whitespaces)
            } else if result.hasPrefix(" ") {
                prefixPostfixBlock(" ", "")
                result = result.trimmingCharacters(in: .whitespaces)
            } else if result.hasSuffix(" ") {
                prefixPostfixBlock("", " ")
                result = result.trimmingCharacters(in: .whitespaces)
            }
        }
        return result
    }
    
    private func shouldRender() -> Bool {
        switch self {
        case .root, .text:
            return !isEmpty()
        case let .element(tag, _):
            return tag.name.lowercased() == "br" || !isEmpty()
        }
    }
}
