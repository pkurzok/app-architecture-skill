// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-Formatting",
    products: [.library(name: "Formatting", targets: ["Formatting"])],
    targets: [
        .target(name: "Formatting"),
        .testTarget(name: "FormattingTests", dependencies: ["Formatting"]),
    ]
)
