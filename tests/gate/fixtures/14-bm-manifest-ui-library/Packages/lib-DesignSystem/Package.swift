// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-DesignSystem",
    products: [.library(name: "DesignSystem", targets: ["DesignSystem"])],
    targets: [
        .target(name: "DesignSystem"),
    ]
)
