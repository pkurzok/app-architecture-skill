// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-BookList",
    platforms: [.iOS(.v18)],
    products: [.library(name: "BookList", targets: ["BookList"])],
    dependencies: [
        .package(path: "../bm-Analytics"),
        .package(path: "../bm-Catalog"),
        .package(path: "../fm-Settings"),
        .package(path: "../lib-Core"),
        .package(path: "../lib-DesignSystem"),
        .package(path: "../lib-Formatting"),
    ],
    targets: [
        .target(name: "BookList", dependencies: [
            .product(name: "Analytics", package: "bm-Analytics"),
            .product(name: "Catalog", package: "bm-Catalog"),
            .product(name: "Settings", package: "fm-Settings"),
            .product(name: "Core", package: "lib-Core"),
            .product(name: "DesignSystem", package: "lib-DesignSystem"),
            .product(name: "Formatting", package: "lib-Formatting"),
        ]),
        .testTarget(name: "BookListTests", dependencies: ["BookList"]),
    ]
)
