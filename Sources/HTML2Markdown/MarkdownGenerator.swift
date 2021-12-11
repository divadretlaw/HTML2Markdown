//
//  MarkdownGenerator.swift
//  
//
//  Created by Matthew Flint on 2021-12-08.
//

import Foundation

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

	func toMarkdownWithError() -> String {
		var markdown = self.toMarkdownWithError(context: [], childIndex: 0)

		// we only want a maximum of two consecutive newlines
		markdown = self.replace(regex: "[\n]{3,}", with: "\n\n", in: markdown)

		return markdown
			.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func toMarkdownWithError(context: OutputContext, childIndex: Int) -> String {
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
				result += child.toMarkdownWithError(context: context, childIndex: index)
			}
		case let .element(tag , children):
			switch tag.name.lowercased() {
			case "p":
				if !context.contains(.isSingleChildInRoot) &&
					!context.contains(.isFirstChild) {
					result += "\n"
				}

				result += output(children).trimmingCharacters(in: .whitespacesAndNewlines)

				if !context.contains(.isSingleChildInRoot) &&
					!context.contains(.isFinalChild) {
					result += "\n"
				}
			case "br":
				if !context.contains(.isFinalChild) {
					result += "  \n"
				}
				// TODO: strip whitespace on the next line of text, immediately after this linebreak
			case "em":
				result += "_" + output(children) + "_"
			case "strong":
				result += "**" + output(children) + "**"
			case "a":
				if let destination = tag.attributes["href"] {
					result += "[\(output(children))](\(destination))"
				} else {
					result += output(children)
				}
			case "ul":
				if !context.contains(.isFirstChild) {
					result += "\n\n"
				}
				result += output(children, context: .isUnorderedList)

				if !context.contains(.isFinalChild) {
					result += "\n\n"
				}
			case "ol":
				if !context.contains(.isFirstChild) {
					result += "\n\n"
				}
				result += output(children, context: .isOrderedList)

				if !context.contains(.isFinalChild) {
					result += "\n\n"
				}
			case "li":
				if context.contains(.isUnorderedList) {
					result += "* \(output(children))"
				}
				if context.contains(.isOrderedList) {
					result += "\(childIndex + 1). \(output(children))"
				}
				if !context.contains(.isFinalChild) {
					result += "\n"
				}
			default:
				result += output(children)
			}
		case let .text(text):
			// Notes:
			// the first space here is an ideographic space, U+3000
			// second space is non-breaking space, U+00A0
			// third space is a regular space, U+0020
			let text = self.replace(regex: "[　  \t\n\r]{1,}", with: " ", in: text /*.trimmingCharacters(in: .newlines)*/)
				.replacingOccurrences(of: "*", with: "\\*")
			if !text.isEmpty {
				result += text
			}
		}

		return result
	}

	private func replace(regex pattern: String, with replacement: String, in string: String) -> String {
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
			return string
		}

		let range = NSRange(location:0, length: string.utf16.count)

		return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacement)
	}

	private func output(_ children: [Element], context: OutputContext = []) -> String {
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
			result += child.toMarkdownWithError(context: context, childIndex: index)
		}
		return result
	}

	private func shouldRender() -> Bool {
		switch self {
		case .root, .text:
			return !self.isEmpty()
		case let .element(tag, _):
			return tag.name.lowercased() == "br" || !self.isEmpty()
		}
	}
}
