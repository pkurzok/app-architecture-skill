// swift-tools-version: 6.2
// Template for a Library module. Replace __NAME__ with the module name — the directory is
// lib-__NAME__ — and keep only the dependencies this module really has.
//
// A library that renders is a UI library: it is iOS-only, so drop macOS from the platforms below,
// and it may drop its test target. A plain library stays UI-free and both platforms stay, which is
// what lets `swift test` run it in seconds without a simulator.
import PackageDescription

let package = Package(
    name: "lib-__NAME__",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "__NAME__", targets: ["__NAME__"])],
    dependencies: [
        // Libraries may depend on other libraries, never upward.
        // .package(path: "../lib-OtherLibrary"),
    ],
    targets: [
        .target(name: "__NAME__", dependencies: [
            // .product(name: "OtherLibrary", package: "lib-OtherLibrary"),
        ]),
        .testTarget(name: "__NAME__Tests", dependencies: ["__NAME__"]),
    ]
)
