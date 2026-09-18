// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-App",
    products: [.library(name: "App", targets: ["App"])],
    targets: [
        .target(name: "App"),
    ]
)
