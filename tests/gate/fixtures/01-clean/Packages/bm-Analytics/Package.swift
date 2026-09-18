// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "bm-Analytics",
    products: [.library(name: "Analytics", targets: ["Analytics"])],
    targets: [
        .target(name: "Analytics"),
        .testTarget(name: "AnalyticsTests", dependencies: ["Analytics"]),
    ]
)
