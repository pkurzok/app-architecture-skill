// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Catalog",
    platforms: [.iOS(.v18)],
    products: [.library(name: "Catalog", targets: ["Catalog"])],
    dependencies: [
        .package(path: "../lib-Core"),
    ],
    targets: [
        .target(name: "Catalog", dependencies: [
            .product(name: "Core", package: "lib-Core"),
        ]),
    ]
)
