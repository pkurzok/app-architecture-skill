// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-BookList",
    products: [.library(name: "BookList", targets: ["BookList"])],
    dependencies: [
        .package(path: "../bm-Catalog"),
        .package(path: "../lib-DesignSystem"),
    ],
    targets: [
        .target(name: "BookList", dependencies: [
            .product(name: "Catalog", package: "bm-Catalog"),
            .product(name: "DesignSystem", package: "lib-DesignSystem"),
        ]),
    ]
)
