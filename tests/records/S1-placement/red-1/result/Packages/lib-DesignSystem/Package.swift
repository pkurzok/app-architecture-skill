// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-DesignSystem",
    platforms: [.iOS(.v18)],
    products: [.library(name: "DesignSystem", targets: ["DesignSystem"])],
    dependencies: [
        .package(path: "../lib-Core"),
    ],
    targets: [
        .target(name: "DesignSystem", dependencies: [
            .product(name: "Core", package: "lib-Core"),
        ]),
    ]
)
