//
//  HTMLEntityDecoder.swift
//
//
//  Created by Matthew Flint on 2021-12-13.
//

import Foundation

public enum HTMLEntityDecoder {
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
    
    public static func entityDecode(_ string: String) -> String {
        var result = string
        
        for (entity, replacement) in Self.htmlEntityMap {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        
        return result
    }
}
