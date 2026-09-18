import Foundation

/// Fixture override of the template's defaults.
enum ArchitectureConfig {
    static let appName = "App"
    static let appSources = "App/Sources"
    static let extraUIFrameworks: Set<String> = [
        "MarkdownUI",
    ]
    static let uiBoundaryAllowlist: Set<String> = []
}
