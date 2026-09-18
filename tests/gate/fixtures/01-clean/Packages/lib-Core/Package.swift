// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-Core",
    products: [.library(name: "Core", targets: ["Core"])],
    dependencies: [
        .package(path: "../lib-Formatting"),
    ],
    targets: [
        .target(name: "Core", dependencies: [
            .product(name: "Formatting", package: "lib-Formatting"),
        ]),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),
    ]
)
