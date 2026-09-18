import SwiftUI

/// Builds the settings screen. Injected by the app shell, called by whoever presents it.
///
/// `Equatable` on a stable `id` rather than a bare `() -> AnyView` environment value: SwiftUI
/// cannot compare function values, so a key holding a raw closure makes every reader invalidate
/// on *any* environment write. Comparing the id gives the framework an honest answer — two seams
/// built from the same registration are the same seam.
public struct SettingsContent: Equatable, Sendable {
    private let id: String
    // `@MainActor @Sendable` so the type is `Sendable` and `unavailable` can be a `static let`
    // under Swift 6. The closure only ever runs while building a view, which is main-actor work.
    private let make: @MainActor @Sendable () -> AnyView

    public init(id: String, make: @escaping @MainActor @Sendable () -> AnyView) {
        self.id = id
        self.make = make
    }

    @MainActor
    public func callAsFunction() -> AnyView {
        make()
    }

    public static let unavailable = SettingsContent(id: "unavailable") { AnyView(EmptyView()) }

    public static func == (lhs: SettingsContent, rhs: SettingsContent) -> Bool {
        lhs.id == rhs.id
    }
}

public extension EnvironmentValues {
    // The default is a `static let`, not a fresh expression: `@Entry` re-evaluates its default on
    // every read that falls back to it, so a default that allocates would invalidate readers on
    // every unrelated environment write.
    @Entry var settingsContent: SettingsContent = .unavailable
}
