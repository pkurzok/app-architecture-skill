// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-DesignSystem",
    platforms: [.iOS(.v18)],
    products: [.library(name: "DesignSystem", targets: ["DesignSystem"])],
    targets: [
        .target(name: "DesignSystem"),
    ]
)
