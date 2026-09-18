// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-Widgets",
    products: [.library(name: "Widgets", targets: ["Widgets"])],
    targets: [
        .target(name: "Widgets"),
    ]
)
