//
//  String+Extensions.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation

extension String {
    private static let htmlEntityMap = [
        "&quot;": "\"",
        "&#34;": "\"",
        "&amp;": "&",
        "&#38;": "&",
        "&apos;": "'",
        "&#39;": "'",
        "&lt;": "<",
        "&#60;": "<",
        "&gt;": ">",
        "&#62;": ">",
        "&nbsp;": " ",
        "&#160;": " ",
        "&euro;": "€",
        "&#128;": "€",
        "&pound;": "£",
        "&#163;": "£",
        "&copy;": "©",
        "&#169;": "©",
        "&eacute;": "é",
        "&#233;": "é",
        "&Eacute;": "É",
        "&#201;": "É"
    ]
    
    func entityDecoded() -> String {
        var result = self
        
        for (entity, replacement) in Self.htmlEntityMap {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        
        return result
    }
}
