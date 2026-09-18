import Foundation
import Testing

/// Wires the rules to Swift Testing. One test per rule, each reporting *every* violation it found,
/// so a single run tells you the whole story instead of one line of it.
@Suite("Architecture")
struct ArchitectureTests {
    static let registry = try! ModuleRegistry.discover()

    @Test("Registry found the app shell and at least one module")
    func registryIsPopulated() {
        // Deliberately not "one of every layer": a young project may have no bm- module yet.
        #expect(Self.registry[ArchitectureConfig.appName]?.hasSourcesDirectory == true,
                "no app sources at \(ArchitectureConfig.appSources)")
        #expect(!Self.registry.packageModules.isEmpty, "no modules found under Packages/")
    }

    @Test("Modules import their own layer or lower, never a sibling feature")
    func respectsLayering() {
        record(Rules.layering(Self.registry))
    }

    @Test("Manifests declare no dependency the code may not import")
    func manifestsRespectLayering() {
        record(Rules.manifestLayering(Self.registry))
    }

    @Test("Business modules are free of UI")
    func businessIsUIFree() {
        record(Rules.businessIsUIFree(Self.registry))
    }

    @Test("Every ui-boundary marker is signed off, and every sign-off has a marker")
    func boundaryMarkersAreHonest() {
        record(Rules.boundaryMarkersAreHonest(Self.registry))
    }

    @Test("Business modules and plain libraries ship Swift Testing tests")
    func testGate() {
        record(Rules.testGate(Self.registry))
    }

    @Test("Module names follow the directory convention and are unique")
    func naming() {
        record(Rules.naming(Self.registry))
    }

    private func record(_ violations: [Violation]) {
        for violation in violations.sorted(by: { $0.message < $1.message }) {
            Issue.record(Comment(rawValue: violation.message))
        }
    }
}

/// The parsers are the part of the gate that can be wrong without any rule looking wrong, so they
/// are tested directly.
@Suite("Parsing")
struct ParsingTests {

    @Test("Reads the module name out of an import line", arguments: [
        ("import Foundation", "Foundation"),
        ("    import Catalog", "Catalog"),
        ("import struct Foo.Bar", "Foo"),
        ("@testable import Catalog", "Catalog"),
        ("@preconcurrency import Analytics", "Analytics"),
        ("@_implementationOnly import Vendor", "Vendor"),
        ("@_spi(Internal) import Catalog", "Catalog"),
        ("public import Core", "Core"),
        ("fileprivate import Core", "Core"),
        ("@preconcurrency public import Core", "Core"),
        ("import UIKit // ui-boundary: thumbnail rendering", "UIKit"),
        ("  import UIKit", "UIKit"),
    ])
    func parsesModuleName(line: String, expected: String) {
        #expect(ModuleRegistry.parseImport(in: line)?.module == expected)
    }

    @Test("Lines that are not imports", arguments: [
        "// import Catalog",
        "    // import Catalog",
        "#if canImport(UIKit)",
        "#endif",
        "let importer = Importer()",
        "func importAll() {}",
        "",
    ])
    func rejectsNonImports(line: String) {
        #expect(ModuleRegistry.parseImport(in: line) == nil)
    }

    @Test("Reads the ui-boundary reason", arguments: [
        ("import UIKit", String?.none),
        ("import UIKit // thumbnails", String?.none),
        ("import UIKit // ui-boundary: renders the cover thumbnail", "renders the cover thumbnail"),
        ("import UIKit  //  ui-boundary:  spaced out ", "spaced out"),
        ("import UIKit // ui-boundary:", ""),
        ("import UIKit // ui-boundary", ""),
    ])
    func parsesBoundaryReason(line: String, expected: String?) {
        #expect(ModuleRegistry.parseImport(in: line)?.boundaryReason == expected)
    }

    @Test("Recognises a @Test attribute line", arguments: [
        ("@Test func loadsBooks()", true),
        ("    @Test(\"Sorts by title\", arguments: titles)", true),
        ("@Test", true),
        ("@Suite(\"Catalog\") struct CatalogTests {", false),
        ("@testable import Catalog", false),
        ("// @Test disabled for now", false),
        ("@TestableThing var flag", false),
    ])
    func recognisesTestAttribute(line: String, expected: Bool) {
        #expect(ModuleRegistry.declaresTest(in: line) == expected)
    }
}
