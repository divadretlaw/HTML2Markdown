//
//  String+Extensions.swift
//  HTML2Markdown
//
//  Created by David Walter on 01.02.23.
//

import Foundation
import SwiftSoup

extension String {
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var removingHtmlEntityEncoding: String? {
        do {
            return try Entities.unescape(string: self, strict: false)
        } catch {
            return nil
        }
    }
}
