import Foundation

/// Architectural layer, ranked so that "upward" imports can be detected numerically.
/// Higher rank may import lower rank, never the reverse.
enum Layer: Int, Sendable, CustomStringConvertible {
    case library = 0
    case business = 1
    case feature = 2
    case app = 3

    /// Maps a `Packages/` directory prefix to its layer. Returns `nil` for non-module directories.
    static func fromPrefix(_ directoryName: String) -> Layer? {
        if directoryName.hasPrefix("lib-") { return .library }
        if directoryName.hasPrefix("bm-") { return .business }
        if directoryName.hasPrefix("fm-") { return .feature }
        return nil
    }

    var description: String {
        switch self {
        case .library: "Library"
        case .business: "Business"
        case .feature: "Feature"
        case .app: "App"
        }
    }
}

/// One `import` line, kept with its location so a violation can point at it.
struct ImportStatement: Sendable, Hashable {
    let module: String
    /// Repository-root-relative path of the file the import was read from.
    let path: String
    let line: Int
    /// Text following `// ui-boundary:` on the same line. `nil` when the line carries no marker,
    /// `""` when the marker was written without a reason.
    let boundaryReason: String?

    /// Whether the line declares itself a reviewed UI boundary. Says nothing about whether that
    /// declaration is honest — ``Rules/boundaryMarkersAreHonest(_:)`` decides that.
    var declaresBoundary: Bool { boundaryReason != nil }
}

/// A single module discovered by scanning the repository tree.
struct Module: Sendable {
    let name: String
    let layer: Layer
    /// The `Packages/` directory this module came from, e.g. `lib-Core`. `nil` for the app shell.
    let directoryName: String?
    /// Every `import` in this module's `Sources/`, sorted by file then line.
    let imports: [ImportStatement]
    /// Number of `@Test` declarations under `Tests/`; zero when the directory is missing.
    let testCount: Int
    /// Module names imported by the test sources, so a stray XCTest dependency can be spotted.
    let testImports: Set<String>
    /// Sibling packages named by `.package(path: "../<dir>")` in `Package.swift`.
    let declaredLocalDependencies: [String]
    /// Whether `Sources/<name>` exists — the directory convention the product name depends on.
    let hasSourcesDirectory: Bool
    /// A library that renders. Derived by the registry, never declared.
    var isUILibrary = false
    /// Why ``isUILibrary`` is true, phrased as the clause a violation message appends:
    /// `imports UIKit in Packages/lib-Core/Sources/Core/Badge.swift:3`.
    var uiReason: String?

    /// Layer rule: a module may import its own layer or any lower layer, never upward.
    /// The feature-sibling restriction is applied separately in the rules.
    func mayImport(_ target: Layer) -> Bool {
        target.rawValue <= layer.rawValue
    }

    /// Repository-root-relative package directory, e.g. `Packages/lib-Core`.
    var packagePath: String {
        directoryName.map { "Packages/\($0)" } ?? ArchitectureConfig.appSources
    }
}

/// Discovers every module in the repo and the app target, deriving layer + name from the directory
/// convention so new modules are covered automatically (no central list to maintain).
struct ModuleRegistry: Sendable {
    let root: URL
    let modules: [Module]

    subscript(name: String) -> Module? {
        modules.first { $0.name == name }
    }

    /// Every `Packages/*` module. The app shell is left out: it deliberately has no test target,
    /// because any logic worth testing lives in a feature or business module.
    var packageModules: [Module] { modules.filter { $0.layer != .app } }

    /// The module a `.package(path: "../<dir>")` entry points at.
    func moduleForDirectory(_ directoryName: String) -> Module? {
        modules.first { $0.directoryName == directoryName }
    }

    static func discover(root explicitRoot: URL? = nil) throws -> ModuleRegistry {
        let root = try (explicitRoot ?? repoRoot()).resolvingSymlinksInPath()
        var modules: [Module] = []

        // Scan Packages/* for module packages (skip the architecture test package itself).
        let packagesDir = root.appendingPathComponent("Packages")
        let entries = (try? FileManager.default.contentsOfDirectory(
            at: packagesDir, includingPropertiesForKeys: [.isDirectoryKey])) ?? []
        for entry in entries.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let dirName = entry.lastPathComponent
            guard dirName != "ArchitectureTests",
                  let layer = Layer.fromPrefix(dirName) else { continue }
            let moduleName = String(dirName.drop(while: { $0 != "-" }).dropFirst())
            let sources = entry.appendingPathComponent("Sources")
            let tests = entry.appendingPathComponent("Tests")
            modules.append(Module(
                name: moduleName,
                layer: layer,
                directoryName: dirName,
                imports: try collectImports(under: sources, root: root),
                testCount: try countTests(under: tests),
                testImports: Set(try collectImports(under: tests, root: root).map(\.module)),
                declaredLocalDependencies: try localDependencies(
                    ofManifestAt: entry.appendingPathComponent("Package.swift")),
                hasSourcesDirectory: FileManager.default.fileExists(
                    atPath: sources.appendingPathComponent(moduleName).path)
            ))
        }

        // Add the app shell. It may import anything, so it only matters as an import target
        // and as the name no module may reuse.
        let appSources = root.appendingPathComponent(ArchitectureConfig.appSources)
        modules.append(Module(
            name: ArchitectureConfig.appName,
            layer: .app,
            directoryName: nil,
            imports: try collectImports(under: appSources, root: root),
            testCount: 0,
            testImports: [],
            declaredLocalDependencies: [],
            hasSourcesDirectory: FileManager.default.fileExists(atPath: appSources.path)
        ))

        return ModuleRegistry(root: root, modules: deriveUILibraries(in: modules))
    }

    /// A library that renders is a UI library, and so is a library that imports one. Computing it
    /// as a fixed point keeps the category derived — there is no fifth prefix and no list.
    private static func deriveUILibraries(in modules: [Module]) -> [Module] {
        var modules = modules
        let localNames = Set(modules.map(\.name))
        let frameworks = UIFrameworks.all()
        var changed = true
        while changed {
            changed = false
            let uiLibraryNames = Set(modules.filter(\.isUILibrary).map(\.name))
            for index in modules.indices where modules[index].layer == .library {
                guard !modules[index].isUILibrary else { continue }
                for statement in modules[index].imports where !statement.declaresBoundary {
                    // A local module wins over the deny-list: `lib-Charts` is our Charts, not Apple's.
                    if localNames.contains(statement.module) {
                        guard uiLibraryNames.contains(statement.module) else { continue }
                        modules[index].uiReason =
                            "imports UI library \(statement.module) in \(statement.path):\(statement.line)"
                    } else {
                        guard frameworks.contains(statement.module) else { continue }
                        modules[index].uiReason =
                            "imports \(statement.module) in \(statement.path):\(statement.line)"
                    }
                    modules[index].isUILibrary = true
                    changed = true
                    break
                }
            }
        }
        return modules
    }

    /// The fixture runner points the registry at a tree it just built; everything else walks up
    /// from this file until a directory contains both `Packages/` and `project.yml`.
    static func repoRoot() throws -> URL {
        if let override = ProcessInfo.processInfo.environment["ARCHITECTURE_TESTS_ROOT"],
           !override.isEmpty {
            return URL(fileURLWithPath: override)
        }
        var dir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let fm = FileManager.default
        while dir.path != "/" {
            let hasPackages = fm.fileExists(atPath: dir.appendingPathComponent("Packages").path)
            let hasProject = fm.fileExists(atPath: dir.appendingPathComponent("project.yml").path)
            if hasPackages && hasProject { return dir }
            dir = dir.deletingLastPathComponent()
        }
        throw RegistryError.repoRootNotFound
    }

    /// Parses every `import` under `directory` (recursively), keeping file and line.
    private static func collectImports(under directory: URL, root: URL) throws -> [ImportStatement] {
        var statements: [ImportStatement] = []
        for url in try swiftFiles(under: directory) {
            let relative = relativePath(of: url, from: root)
            let contents = try String(contentsOf: url, encoding: .utf8)
            for (offset, line) in contents.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                guard let parsed = parseImport(in: String(line)) else { continue }
                statements.append(ImportStatement(
                    module: parsed.module,
                    path: relative,
                    line: offset + 1,
                    boundaryReason: parsed.boundaryReason
                ))
            }
        }
        return statements.sorted { ($0.path, $0.line) < ($1.path, $1.line) }
    }

    /// Counts `@Test` attributes in every `.swift` file under `directory` (recursively).
    private static func countTests(under directory: URL) throws -> Int {
        var count = 0
        for url in try swiftFiles(under: directory) {
            let contents = try String(contentsOf: url, encoding: .utf8)
            count += contents.split(whereSeparator: \.isNewline).count { declaresTest(in: String($0)) }
        }
        return count
    }

    /// Every `.swift` file under `directory`, sorted so violations come out in a stable order.
    private static func swiftFiles(under directory: URL) throws -> [URL] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        var files: [URL] = []
        for case let url as URL in enumerator where url.pathExtension == "swift" {
            files.append(url)
        }
        return files.sorted { $0.path < $1.path }
    }

    /// Sibling packages a manifest depends on, as directory names: `.package(path: "../lib-Core")`
    /// yields `lib-Core`. Remote dependencies carry no `path:` and are ignored.
    static func localDependencies(ofManifestAt url: URL) throws -> [String] {
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        var directories: [String] = []
        for line in contents.split(whereSeparator: \.isNewline) {
            // A commented-out dependency is not a dependency.
            let code = line.range(of: "//").map { line[..<$0.lowerBound] } ?? line
            guard let range = code.range(of: ".package(path:") else { continue }
            let rest = code[range.upperBound...].drop(while: { $0 != "\"" }).dropFirst()
            let literal = rest.prefix { $0 != "\"" }
            let directory = literal.split(separator: "/").last.map(String.init) ?? String(literal)
            guard !directory.isEmpty else { continue }
            directories.append(directory)
        }
        return directories
    }

    /// Whether `line` opens a Swift Testing `@Test` attribute — bare, or with a display name / traits.
    static func declaresTest(in line: String) -> Bool {
        let trimmed = line.drop(while: \.isWhitespace)
        guard trimmed.hasPrefix("@Test") else { return false }
        guard let next = trimmed.dropFirst("@Test".count).first else { return true }
        return next == "(" || next.isWhitespace
    }

    /// Parses an `import` line into its top-level module name and its `// ui-boundary:` reason.
    ///
    /// Handles any run of leading attributes (`@testable`, `@preconcurrency`, `@_spi(Internal)`)
    /// and an access level (`public import`), plus the `import struct Foo.Bar` spelling. A
    /// commented-out import is not an import.
    static func parseImport(in line: String) -> (module: String, boundaryReason: String?)? {
        var code = Substring(line).drop(while: \.isWhitespace)
        guard !code.hasPrefix("//") else { return nil }

        var comment: Substring?
        if let commentStart = code.range(of: "//") {
            comment = code[commentStart.upperBound...]
            code = code[..<commentStart.lowerBound]
        }

        let accessLevels: Set<Substring> = ["public", "package", "internal", "fileprivate", "private"]
        while true {
            code = code.drop(while: \.isWhitespace)
            if code.hasPrefix("@") {
                code = code.dropFirst().drop(while: { $0.isLetter || $0.isNumber || $0 == "_" })
                if code.hasPrefix("(") { code = code.drop(while: { $0 != ")" }).dropFirst() }
                continue
            }
            let token = code.prefix(while: { $0.isLetter })
            if accessLevels.contains(token) {
                code = code.dropFirst(token.count)
                continue
            }
            break
        }

        guard code.hasPrefix("import"),
              let afterKeyword = code.dropFirst("import".count).first,
              afterKeyword.isWhitespace else { return nil }
        var rest = code.dropFirst("import".count).drop(while: \.isWhitespace)

        // `import struct Foo.Bar` names a declaration, not the module — skip the kind keyword.
        let kinds: Set<Substring> = ["struct", "class", "enum", "protocol", "func", "let", "var", "typealias"]
        let firstToken = rest.prefix(while: { $0.isLetter })
        if kinds.contains(firstToken) {
            rest = rest.dropFirst(firstToken.count).drop(while: \.isWhitespace)
        }

        // Take the top-level module name (before any `.` submodule path).
        let name = rest.prefix { $0.isLetter || $0.isNumber || $0 == "_" }
        guard !name.isEmpty else { return nil }
        return (String(name), boundaryReason(in: comment))
    }

    /// Reads `// ui-boundary: <reason>` from an import line's trailing comment.
    /// Returns `nil` for no marker, `""` for a marker written without a reason.
    private static func boundaryReason(in comment: Substring?) -> String? {
        guard let comment else { return nil }
        let trimmed = comment.drop(while: \.isWhitespace)
        guard trimmed.hasPrefix(boundaryMarker) else { return nil }
        var reason = trimmed.dropFirst(boundaryMarker.count)
        if reason.hasPrefix(":") { reason = reason.dropFirst() }
        return String(reason).trimmingCharacters(in: .whitespaces)
    }

    /// The marker that declares an import a reviewed UI boundary.
    static let boundaryMarker = "ui-boundary"

    private static func relativePath(of url: URL, from root: URL) -> String {
        let rootPath = root.path.hasSuffix("/") ? root.path : root.path + "/"
        let path = url.standardizedFileURL.path
        return path.hasPrefix(rootPath) ? String(path.dropFirst(rootPath.count)) : path
    }
}

enum RegistryError: Error {
    case repoRootNotFound
}
