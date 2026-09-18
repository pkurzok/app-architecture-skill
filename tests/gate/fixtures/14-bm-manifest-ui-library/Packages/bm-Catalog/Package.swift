// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Catalog",
    products: [.library(name: "Catalog", targets: ["Catalog"])],
    dependencies: [
        .package(path: "../lib-DesignSystem"),
    ],
    targets: [
        .target(name: "Catalog", dependencies: [
            .product(name: "DesignSystem", package: "lib-DesignSystem"),
        ]),
        .testTarget(name: "CatalogTests", dependencies: ["Catalog"]),
    ]
)
