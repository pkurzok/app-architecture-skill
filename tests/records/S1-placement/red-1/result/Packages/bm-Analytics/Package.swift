// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Analytics",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "Analytics", targets: ["Analytics"])],
    dependencies: [
        .package(path: "../lib-Core"),
    ],
    targets: [
        .target(name: "Analytics", dependencies: [
            .product(name: "Core", package: "lib-Core"),
        ]),
        .testTarget(name: "AnalyticsTests", dependencies: ["Analytics"]),
    ]
)
