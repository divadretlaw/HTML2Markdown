//
//  RawTextGenerator.swift
//  HTML2Markdown
//
//  Created by David Walter on 30.01.23.
//

import Foundation

public enum RawTextGenerator {
    public struct Options: OptionSet {
        public let rawValue: Int
        
        /// Copy link text instead of URL
        public static let keepLinkText = Options(rawValue: 1 << 0)
        /// Try to respect Mastodon classes
        public static let mastodon = Options(rawValue: 1 << 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

public extension Element {
    /// Extract the raw text from the parsed HTML
    ///
    /// - Parameter options: Options to customize the formatted text
    func rawText(options: RawTextGenerator.Options = []) -> String {
        return rawText(options: options, context: [], childIndex: 0)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func rawText(
        options: RawTextGenerator.Options,
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
                result += child.rawText(options: options, context: context, childIndex: index)
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
                result += "\(prefix)" + text + "\(postfix)"
            case "strong":
                var prefix = ""
                var postfix = ""
                
                let blockToPass: (String, String) -> Void = {
                    prefix = $0
                    postfix = $1
                }
                
                let text = output(children, options: options, prefixPostfixBlock: blockToPass)
                
                result += "\(prefix)" + text + "\(postfix)"
            case "a":
                if let destination = tag.attributes["href"] {
                    if options.contains(.keepLinkText) {
                        result += "\(output(children, options: options))"
                    } else {
                        result += destination
                    }
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
                    let bullet = "•"
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
            result += text
        }
        
        return result
    }
    
    private func output(
        _ children: [Element],
        options: RawTextGenerator.Options,
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
            result += child.rawText(options: options, context: context, childIndex: index, prefixPostfixBlock: prefixPostfixBlock)
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
            return !isEmpty
        case let .element(tag, _):
            return tag.name.lowercased() == "br" || !isEmpty
        }
    }
}
