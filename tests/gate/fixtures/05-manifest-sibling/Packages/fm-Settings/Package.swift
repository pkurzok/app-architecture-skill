// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-Settings",
    products: [.library(name: "Settings", targets: ["Settings"])],
    targets: [
        .target(name: "Settings"),
    ]
)
