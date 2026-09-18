// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Store",
    products: [.library(name: "Store", targets: ["Store"])],
    targets: [
        .target(name: "Store"),
        .testTarget(name: "StoreTests", dependencies: ["Store"]),
    ]
)
