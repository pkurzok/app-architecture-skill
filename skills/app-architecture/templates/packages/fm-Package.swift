// swift-tools-version: 6.2
// Template for a Feature module. Replace __NAME__ with the module name — the directory is
// fm-__NAME__ — and keep only the dependencies this module really has.
//
// Features are the only modules that may import a UI library, so they are iOS-only and their
// tests need a simulator. If this feature has nothing worth testing, delete the test target and
// its Tests/ directory rather than leaving an empty one behind.
import PackageDescription

let package = Package(
    name: "fm-__NAME__",
    platforms: [.iOS(.v18)],
    products: [.library(name: "__NAME__", targets: ["__NAME__"])],
    dependencies: [
        // Features may depend on business modules and libraries — never on another feature.
        // To show a sibling feature's screen, use a seam injected by the app shell.
        // .package(path: "../bm-SomeBusiness"),
        // .package(path: "../lib-DesignSystem"),
    ],
    targets: [
        .target(name: "__NAME__", dependencies: [
            // .product(name: "SomeBusiness", package: "bm-SomeBusiness"),
            // .product(name: "DesignSystem", package: "lib-DesignSystem"),
        ]),
        .testTarget(name: "__NAME__Tests", dependencies: ["__NAME__"]),
    ]
)
