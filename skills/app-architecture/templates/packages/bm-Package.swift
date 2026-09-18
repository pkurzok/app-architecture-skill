// swift-tools-version: 6.2
// Template for a Business module. Replace __NAME__ with the module name — the directory is
// bm-__NAME__ — and keep only the dependencies this module really has.
//
// A business module holds domain logic and renders nothing, so it never depends on a UI library
// and never imports a UI framework. That is what keeps macOS in the platforms below, and with it
// a `swift test` run that needs no simulator.
import PackageDescription

let package = Package(
    name: "bm-__NAME__",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "__NAME__", targets: ["__NAME__"])],
    dependencies: [
        // Business modules may depend on other business modules and on plain libraries.
        // .package(path: "../bm-OtherBusiness"),
        // .package(path: "../lib-SomeLibrary"),
        // Third-party SDKs are declared by the module that consumes them:
        // .package(url: "https://github.com/example/some-sdk", from: "1.0.0"),
    ],
    targets: [
        .target(name: "__NAME__", dependencies: [
            // .product(name: "OtherBusiness", package: "bm-OtherBusiness"),
            // .product(name: "SomeLibrary", package: "lib-SomeLibrary"),
        ]),
        .testTarget(name: "__NAME__Tests", dependencies: ["__NAME__"]),
    ]
)
