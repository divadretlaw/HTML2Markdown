//
//  MarkdownGenerator.swift
//  HTML2Markdown
//
//  Created by Matthew Flint on 2021-12-08.
//

import Foundation
import SwiftSoup

public enum MarkdownGenerator {
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int
        
        /// Output a pretty bullet `•` instead of an asterisk, for unordered lists
        public static let unorderedListBullets = Options(rawValue: 1 << 0)
        /// Escape existing markdown syntax in order to prevent them being rendered
        public static let escapeMarkdown = Options(rawValue: 1 << 1)
        /// Try to respect Mastodon classes
        public static let mastodon = Options(rawValue: 1 << 10)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension Node {
    /// The parsed HTML formatted as Markddown
    ///
    /// - Parameter options: Options to customize the formatted text
    public func markdownFormatted(options: MarkdownGenerator.Options = []) -> String {
        var markdown = markdownFormattedRoot(options: options, context: [], childIndex: 0)
        
        // we only want a maximum of two consecutive newlines
        markdown = replace(regex: "[\n]{3,}", with: "\n\n", in: markdown)
        
        if options.contains(.mastodon) {
            markdown = markdown
                // Add space between hashtags and mentions that follow each other
                .replacingOccurrences(of: ")[", with: ") [")
        }
        
        return markdown
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func markdownFormattedRoot(
        options: MarkdownGenerator.Options,
        context: OutputContext,
        childIndex: Int,
        prefixPostfixBlock: ((String, String) -> Void)? = nil
    ) -> String {
        var result = ""
        let childrenWithContent = getChildNodes().filter { $0.shouldRender() }
        
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
            result += child.markdownFormatted(options: options, context: context, childIndex: index)
        }
        
        return result
    }
    
    private func markdownFormatted(
        options: MarkdownGenerator.Options,
        context: OutputContext,
        childIndex: Int,
        prefixPostfixBlock: ((String, String) -> Void)? = nil
    ) -> String {
        var result = ""
        let children = getChildNodes()
        
        switch nodeName() {
        case "pre":
            if context.contains(.isPre) {
                result += output(children, options: options, context: .isCode)
            } else {
                let text = output(children, options: options, context: .isPre)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let formatted = ["```", text, "```"]
                    .joined(separator: "\n")
                    .fenced(with: "\n")
                result += formatted
            }
        case "code":
            if context.contains(.isCode) {
                result += output(children, options: options, context: .isCode)
            } else if context.contains(.isPre) {
                result += output(children, options: options, context: .isCode)
            } else {
                let text = output(children, options: options, context: .isCode)
                let formatted = text.fenced(with: "`")
                result += formatted
            }
        case "span":
            if let classes = getAttributes()?.get(key: "class").split(separator: " ") {
                if options.contains(.mastodon) {
                    if classes.contains("invisible") {
                        break
                    }
                    
                    result += output(children, options: options)
                    
                    if classes.contains("ellipsis") {
                        result += "…"
                    }
                } else {
                    result += output(children, options: options)
                }
            } else {
                result += output(children, options: options)
            }
        case "p":
            if !context.contains(.isSingleChildInRoot),
               !context.contains(.isFirstChild) {
                result += "\n"
            }
            
            result += output(children, options: options).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !context.contains(.isSingleChildInRoot), !context.contains(.isFinalChild) {
                result += "\n"
            }
        case "br":
            if !context.contains(.isFinalChild) {
                result += "\n"
            }
        case "em", "i":
            var prefix = ""
            var postfix = ""
            
            let blockToPass: (String, String) -> Void = {
                prefix = $0
                postfix = $1
            }
            
            let text = output(children, options: options, prefixPostfixBlock: blockToPass)
            let formatted = "\(prefix)*\(text)*\(postfix)"
            result += formatted
        case "b", "strong":
            var prefix = ""
            var postfix = ""
            
            let blockToPass: (String, String) -> Void = {
                prefix = $0
                postfix = $1
            }
            
            let text = output(children, options: options, prefixPostfixBlock: blockToPass)
            let formatted = "\(prefix)**\(text)**\(postfix)"
            result += formatted
        case "s", "del":
            var prefix = ""
            var postfix = ""
            
            let blockToPass: (String, String) -> Void = {
                prefix = $0
                postfix = $1
            }
            
            let text = output(children, options: options, prefixPostfixBlock: blockToPass)
            
            result += "\(prefix)~~\(text)~~\(postfix)"
        case "a":
            if !context.contains(.isCode), let destination = getAttributes()?.get(key: "href"), !destination.isEmpty {
                result += "[\(output(children, options: options))](\(destination))"
            } else {
                result += output(children, options: options)
            }
        case "ul":
            if !context.contains(.isFirstChild) {
                result += "\n\n"
            }
            
            let text = output(children, options: options, context: .isUnorderedList)
            result += text
            
            if !context.contains(.isFinalChild) {
                result += "\n\n"
            }
        case "ol":
            if !context.contains(.isFirstChild) {
                result += "\n\n"
            }
            
            let text = output(children, options: options, context: .isOrderedList)
            result += text
            
            if !context.contains(.isFinalChild) {
                result += "\n\n"
            }
        case "li":
            let bullet: String? = if context.contains(.isUnorderedList) {
                options.contains(.unorderedListBullets) ? "•" : "*"
            } else if context.contains(.isOrderedList) {
                "\(childIndex + 1)."
            } else {
                nil
            }
            
            let text = output(children, options: options)
            let formatted = [bullet, text]
                .compactMap { $0 }
                .joined(separator: " ")
            
            if !context.contains(.isFinalChild) {
                result += "\(formatted)\n"
            } else {
                result += formatted
            }
        case "blockquote":
            var prefix = ""
            var postfix = ""
            
            let blockToPass: (String, String) -> Void = {
                prefix = $0
                postfix = $1
            }
            
            let text = output(children, options: options, prefixPostfixBlock: blockToPass)
            let formatted = [prefix, "> \(text)\n", postfix]
                .joined(separator: "\n")
            result += formatted
        case "#text":
            // replace all whitespace with a single space, and escape markdown (if enabled)
            
            // Notes:
            // the first space here is an ideographic space, U+3000
            // second space is non-breaking space, U+00A0
            // third space is a regular space, U+0020
            let replacedText = replace(regex: "[\u{3000}\u{00A0}\u{0020}\t\n\r]{1,}", with: " ", in: description)
            let text = replacedText.removingHtmlEntityEncoding ?? replacedText
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
        default:
            result += output(children, options: options)
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
        _ children: [Node],
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
            result += child.markdownFormatted(options: options, context: context, childIndex: index, prefixPostfixBlock: prefixPostfixBlock)
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
        
        return result.removingHtmlEntityEncoding ?? result
    }
    
    private func shouldRender() -> Bool {
        if let element = self as? TextNode {
            return !element.isBlank()
        }
        
        switch nodeName() {
        case "br":
            return true
        default:
            return !description.isEmpty
        }
    }
}
