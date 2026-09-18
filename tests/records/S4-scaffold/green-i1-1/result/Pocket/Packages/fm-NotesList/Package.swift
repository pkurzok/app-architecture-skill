// swift-tools-version: 6.2
// Template for a Feature module. Replace NotesList with the module name — the directory is
// fm-NotesList — and keep only the dependencies this module really has.
//
// Features are the only modules that may import a UI library, so they are iOS-only and their
// tests need a simulator. If this feature has nothing worth testing, delete the test target and
// its Tests/ directory rather than leaving an empty one behind.
import PackageDescription

let package = Package(
    name: "fm-NotesList",
    platforms: [.iOS(.v18)],
    products: [.library(name: "NotesList", targets: ["NotesList"])],
    dependencies: [
        // Features may depend on business modules and libraries — never on another feature.
        // To show a sibling feature's screen, use a seam injected by the app shell.
        .package(path: "../bm-Notes"),
    ],
    targets: [
        .target(name: "NotesList", dependencies: [
            .product(name: "Notes", package: "bm-Notes"),
        ]),
        .testTarget(name: "NotesListTests", dependencies: [
            "NotesList",
            .product(name: "Notes", package: "bm-Notes"),
        ]),
    ]
)
