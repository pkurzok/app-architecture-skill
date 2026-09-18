import Foundation

/// The only file a project edits after copying this package in.
///
/// Everything else here is convention-driven: modules are discovered from the `Packages/`
/// directory names, so adding a module never means editing a list.
enum ArchitectureConfig {
    /// The app shell's module name, as it appears in violation messages. No package may reuse it.
    static let appName = "App"

    /// The app shell's sources, relative to the repository root. The composition root lives here
    /// and is the one place that may import every layer.
    static let appSources = "App/Sources"

    /// UI frameworks this project adds on top of the built-in deny-list — a third-party view
    /// library, for example. A business module may not import these either.
    static let extraUIFrameworks: Set<String> = []

    /// Repository-root-relative paths of files holding a signed-off `// ui-boundary:` import,
    /// e.g. `Packages/bm-Game/Sources/Game/Card.swift`.
    ///
    /// Growing this list is a human decision. An agent may propose an entry; it never adds one
    /// to turn a red gate green.
    static let uiBoundaryAllowlist: Set<String> = []
}
