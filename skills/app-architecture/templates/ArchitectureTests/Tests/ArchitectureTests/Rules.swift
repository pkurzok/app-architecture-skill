import Foundation

/// One architectural violation, reduced to the single line the gate prints. Keeping the message
/// stable matters: it is what a developer greps for and what the fixture tests compare.
struct Violation: Sendable, Hashable {
    let message: String

    init(_ message: String) { self.message = "ARCH: \(message)" }
}

/// The rules, as pure functions over a registry. Each returns every violation it found, so one
/// run reports all of them instead of stopping at the first.
enum Rules {

    /// Dependencies point down. A module imports its own layer or a lower one, and a feature never
    /// imports a sibling feature — that is what the app shell's seams are for.
    static func layering(_ registry: ModuleRegistry) -> [Violation] {
        var violations: [Violation] = []
        for module in registry.modules {
            for statement in module.imports {
                // An unknown name is a framework, not one of ours.
                guard let target = registry[statement.module], target.name != module.name else { continue }
                let site = "\(statement.path):\(statement.line)"
                if !module.mayImport(target.layer) {
                    violations.append(Violation(
                        "\(module.name) (\(module.layer)) imports \(target.name) (\(target.layer))"
                        + " — upward import (\(site))"))
                }
                if module.layer == .feature && target.layer == .feature {
                    violations.append(Violation(
                        "Feature \(module.name) imports sibling feature \(target.name) (\(site))"))
                }
            }
        }
        return violations
    }

    /// The same rule one level up: a manifest may not even *declare* a dependency the code is
    /// forbidden to import. Catching it here names the line you have to delete.
    static func manifestLayering(_ registry: ModuleRegistry) -> [Violation] {
        var violations: [Violation] = []
        for module in registry.packageModules {
            for directory in module.declaredLocalDependencies {
                guard let target = registry.moduleForDirectory(directory) else { continue }
                let manifest = "\(module.packagePath)/Package.swift declares ../\(directory)"
                if !module.mayImport(target.layer) {
                    violations.append(Violation("\(manifest) — upward dependency"))
                } else if module.layer == .feature && target.layer == .feature
                            && target.name != module.name {
                    violations.append(Violation("\(manifest) — sibling feature dependency"))
                }
            }
        }
        return violations
    }

    /// The golden rule. A business module holds domain logic, so it renders nothing: no UI
    /// framework, and no library that renders. An import carrying a `// ui-boundary:` marker is a
    /// declared exception and is judged by ``boundaryMarkersAreHonest(_:)`` instead.
    static func businessIsUIFree(_ registry: ModuleRegistry) -> [Violation] {
        var violations: [Violation] = []
        let frameworks = UIFrameworks.all()
        for module in registry.modules where module.layer == .business {
            for statement in module.imports where !statement.declaresBoundary {
                let site = "\(statement.path):\(statement.line)"
                if let target = registry[statement.module] {
                    guard target.isUILibrary, let reason = target.uiReason else { continue }
                    violations.append(Violation(
                        "\(module.name) depends on UI library \(target.name) (\(site));"
                        + " \(target.name) \(reason)"))
                } else if frameworks.contains(statement.module) {
                    violations.append(Violation(
                        "\(module.name) imports \(statement.module)"
                        + " — UI framework in business module (\(site))"))
                }
            }
            for directory in module.declaredLocalDependencies {
                guard let target = registry.moduleForDirectory(directory), target.isUILibrary else { continue }
                violations.append(Violation(
                    "\(module.packagePath)/Package.swift declares ../\(directory)"
                    + " — business module depends on UI library \(target.name)"))
            }
        }
        return violations
    }

    /// A boundary exception is a reviewed decision, so the marker in the file and the entry in
    /// ``ArchitectureConfig/uiBoundaryAllowlist`` must agree in both directions — a marker nobody
    /// signed off is as dishonest as a list entry nothing backs.
    static func boundaryMarkersAreHonest(_ registry: ModuleRegistry) -> [Violation] {
        var violations: [Violation] = []
        var markedPaths: Set<String> = []
        for module in registry.modules where module.layer == .business || module.layer == .library {
            for statement in module.imports {
                guard let reason = statement.boundaryReason else { continue }
                markedPaths.insert(statement.path)
                let site = "\(statement.path):\(statement.line)"
                if reason.isEmpty {
                    violations.append(Violation("\(site): ui-boundary marker needs a reason"))
                }
                if !ArchitectureConfig.uiBoundaryAllowlist.contains(statement.path) {
                    violations.append(Violation(
                        "\(site): ui-boundary marker is not listed in"
                        + " ArchitectureConfig.uiBoundaryAllowlist"))
                }
            }
        }
        for path in ArchitectureConfig.uiBoundaryAllowlist.sorted() where !markedPaths.contains(path) {
            violations.append(Violation(
                "ArchitectureConfig.uiBoundaryAllowlist lists \(path),"
                + " but that file has no ui-boundary marker"))
        }
        return violations
    }

    /// Business modules and plain libraries are UI-free, so they run under `swift test` in
    /// seconds — there is no excuse for them to be untested. Feature modules and UI libraries need
    /// a simulator, so their tests stay optional.
    static func testGate(_ registry: ModuleRegistry) -> [Violation] {
        var violations: [Violation] = []
        for module in registry.packageModules {
            let isTestable = module.layer == .business
                || (module.layer == .library && !module.isUILibrary)
            guard isTestable else { continue }
            if module.testCount == 0 {
                violations.append(Violation("\(module.name) has no @Test under Tests/\(module.name)Tests"))
            }
            if module.testImports.contains("XCTest") {
                violations.append(Violation(
                    "\(module.name) tests import XCTest — write them with Swift Testing"))
            }
        }
        return violations
    }

    /// The directory name is the single source of truth: it carries the layer prefix and, minus
    /// that prefix, the module name. A name that collides with another module or with the app
    /// makes every import ambiguous.
    static func naming(_ registry: ModuleRegistry) -> [Violation] {
        var violations: [Violation] = []
        var counts: [String: Int] = [:]
        for module in registry.packageModules { counts[module.name, default: 0] += 1 }
        var reported: Set<String> = []
        for module in registry.packageModules {
            let collides = (counts[module.name] ?? 0) > 1 || module.name == ArchitectureConfig.appName
            if collides, reported.insert(module.name).inserted {
                violations.append(Violation(
                    "module name \(module.name) is used by more than one package or equals the app name"))
            }
            if !module.hasSourcesDirectory {
                violations.append(Violation(
                    "\(module.packagePath) has no Sources/\(module.name) directory"
                    + " — module name is the directory name minus its prefix"))
            }
        }
        return violations
    }
}
