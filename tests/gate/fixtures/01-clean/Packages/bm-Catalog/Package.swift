// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Catalog",
    products: [.library(name: "Catalog", targets: ["Catalog"])],
    dependencies: [
        .package(path: "../bm-Analytics"),
        .package(path: "../lib-Core"),
    ],
    targets: [
        .target(name: "Catalog", dependencies: [
            .product(name: "Analytics", package: "bm-Analytics"),
            .product(name: "Core", package: "lib-Core"),
        ]),
        .testTarget(name: "CatalogTests", dependencies: ["Catalog"]),
    ]
)
