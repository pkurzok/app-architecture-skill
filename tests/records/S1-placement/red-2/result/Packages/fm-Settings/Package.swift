// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-Settings",
    platforms: [.iOS(.v18)],
    products: [.library(name: "Settings", targets: ["Settings"])],
    dependencies: [
        .package(path: "../bm-Analytics"),
        .package(path: "../bm-Catalog"),
        .package(path: "../lib-DesignSystem"),
    ],
    targets: [
        .target(name: "Settings", dependencies: [
            .product(name: "Analytics", package: "bm-Analytics"),
            .product(name: "Catalog", package: "bm-Catalog"),
            .product(name: "DesignSystem", package: "lib-DesignSystem"),
        ]),
    ]
)
