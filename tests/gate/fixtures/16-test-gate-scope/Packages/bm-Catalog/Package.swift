// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Catalog",
    products: [.library(name: "Catalog", targets: ["Catalog"])],
    targets: [
        .target(name: "Catalog"),
    ]
)
