import SwiftUI

/// Reports that a screen appeared. Injected by the app shell; the design system knows nothing
/// about analytics, and the analytics module knows nothing about SwiftUI.
public struct ScreenTracker: Equatable, Sendable {
    private let id: String
    // `@MainActor @Sendable` so the type is `Sendable` and `disabled` can be a `static let` under
    // Swift 6. The closure only ever runs while a view is on screen, which is main-actor work.
    private let report: @MainActor @Sendable (String) -> Void

    public init(id: String, report: @escaping @MainActor @Sendable (String) -> Void) {
        self.id = id
        self.report = report
    }

    @MainActor
    public func callAsFunction(_ screen: String) {
        report(screen)
    }

    public static let disabled = ScreenTracker(id: "disabled") { _ in }

    public static func == (lhs: ScreenTracker, rhs: ScreenTracker) -> Bool {
        lhs.id == rhs.id
    }
}

public extension EnvironmentValues {
    // The default is a `static let`, not a fresh expression: `@Entry` re-evaluates its default on
    // every read that falls back to it, so a default that allocates would invalidate readers on
    // every unrelated environment write.
    @Entry var screenTracker: ScreenTracker = .disabled
}

private struct TrackScreen: ViewModifier {
    @Environment(\.screenTracker) private var screenTracker

    let name: String

    func body(content: Content) -> some View {
        content.onAppear { screenTracker(name) }
    }
}

public extension View {
    /// Reports this screen's name to analytics when it appears. The whole cost of a new screen.
    func trackScreen(_ name: String) -> some View {
        modifier(TrackScreen(name: name))
    }
}
