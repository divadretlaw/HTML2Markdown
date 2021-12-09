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
		return self.toMarkdownWithError(context: [], childIndex: 0)
	}

	private func toMarkdownWithError(context: OutputContext, childIndex: Int) -> String {
		var result = ""

		switch self {
		case let .root(children):
			for (index, child) in children.enumerated() {
				var context: OutputContext = []
				if children.count == 1 {
					context.insert(.isSingleChildInRoot)
				}
				if index == 0 {
					context.insert(.isFirstChild)
				}
				if index == children.count - 1 {
					context.insert(.isFinalChild)
				}
				result += child.toMarkdownWithError(context: context, childIndex: index)
			}
		case let .element(tag , children):
			switch tag.name.lowercased() {
			case "p":
				result += output(children)

				if !context.contains(.isSingleChildInRoot) &&
					!context.contains(.isFinalChild) {
					result += "\n\n"
				}
			case "br":
				if !context.contains(.isFinalChild) {
					result += "  \n"
				}
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
					result += "\(childIndex + 1) \(output(children))"
				}
				if !context.contains(.isFinalChild) {
					result += "\n"
				}
			default:
				result += output(children)
			}
		case let .text(text):
			result += text
		}

		return result
	}

	private func output(_ children: [Element], context: OutputContext = []) -> String {
		var result = ""
		for (index, child) in children.enumerated() {
			var context = context
			if index == 0 {
				context.insert(.isFirstChild)
			}
			if index == children.count - 1 {
				context.insert(.isFinalChild)
			}
			result += child.toMarkdownWithError(context: context, childIndex: index)
		}
		return result
	}
}
