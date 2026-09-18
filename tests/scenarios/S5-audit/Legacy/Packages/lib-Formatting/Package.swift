// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-Formatting",
    platforms: [.iOS(.v18)],
    products: [.library(name: "Formatting", targets: ["Formatting"])],
    dependencies: [
        .package(path: "../bm-Catalog"),
    ],
    targets: [
        .target(name: "Formatting"),
        .testTarget(name: "FormattingTests", dependencies: ["Formatting"]),
    ]
)
