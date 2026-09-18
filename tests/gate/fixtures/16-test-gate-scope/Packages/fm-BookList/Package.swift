// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-BookList",
    products: [.library(name: "BookList", targets: ["BookList"])],
    targets: [
        .target(name: "BookList"),
    ]
)
