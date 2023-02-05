// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTML2Markdown",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "HTML2Markdown",
            targets: ["HTML2Markdown"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup", from: "2.5.3")
    ],
    targets: [
        .target(
            name: "HTML2Markdown",
            dependencies: ["SwiftSoup"]
        ),
        .testTarget(
            name: "HTML2MarkdownTests",
            dependencies: ["HTML2Markdown"]
        ),
    ]
)
