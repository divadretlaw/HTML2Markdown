//
//  Element+Extensions.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation
import SwiftSoup

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
