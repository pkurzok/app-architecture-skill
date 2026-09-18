// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotesListFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "NotesListFeature", targets: ["NotesListFeature"])
    ],
    dependencies: [
        .package(path: "../NotesKit")
    ],
    targets: [
        .target(name: "NotesListFeature", dependencies: ["NotesKit"]),
        .testTarget(name: "NotesListFeatureTests", dependencies: ["NotesListFeature"])
    ]
)
