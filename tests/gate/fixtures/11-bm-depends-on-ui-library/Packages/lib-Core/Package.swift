// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "lib-Core",
    products: [.library(name: "Core", targets: ["Core"])],
    targets: [
        .target(name: "Core"),
    ]
)
