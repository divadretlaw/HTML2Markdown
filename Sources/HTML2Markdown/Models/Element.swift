//
//  Element.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation

public enum Element {
    case root(children: [Element])
    case element(tag: Tag, children: [Element])
    case text(text: String)
    
    var isEmpty: Bool {
        var result: Bool
        
        switch self {
        case let .root(children):
            result = isEmpty(children)
        case let .element(_, children):
            result = isEmpty(children)
        case let .text(text):
            result = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return result
    }
    
    private func isEmpty(_ children: [Element]) -> Bool {
        return !children.contains { !$0.isEmpty }
    }
}

extension Element {
    struct OutputContext: OptionSet {
        let rawValue: UInt
        
        init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        static let isSingleChildInRoot = OutputContext(rawValue: 1 << 0)
        static let isFirstChild = OutputContext(rawValue: 1 << 1)
        static let isFinalChild = OutputContext(rawValue: 1 << 2)
        static let isUnorderedList = OutputContext(rawValue: 1 << 3)
        static let isOrderedList = OutputContext(rawValue: 1 << 4)
    }
}
