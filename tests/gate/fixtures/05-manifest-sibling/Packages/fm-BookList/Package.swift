// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "fm-BookList",
    products: [.library(name: "BookList", targets: ["BookList"])],
    dependencies: [
        .package(path: "../fm-Settings"),
    ],
    targets: [
        .target(name: "BookList", dependencies: [
            .product(name: "Settings", package: "fm-Settings"),
        ]),
    ]
)
