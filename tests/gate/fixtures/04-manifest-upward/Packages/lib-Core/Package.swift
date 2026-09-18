// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-Core",
    products: [.library(name: "Core", targets: ["Core"])],
    dependencies: [
        .package(path: "../bm-Store"),
    ],
    targets: [
        .target(name: "Core", dependencies: [
            .product(name: "Store", package: "bm-Store"),
        ]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)
