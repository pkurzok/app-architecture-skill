# Feature seams

## The problem

A feature module may never import a sibling feature. So the book list cannot present the
settings screen, even though presenting it is obviously the book list's job.

The same shape shows up a second way: a reusable view modifier in a UI library needs business
behaviour — screen tracking, say. The modifier cannot import `bm-Analytics` (a library may not
import upward), and `bm-Analytics` cannot import SwiftUI (the golden rule).

Both are the same knot, and only the app shell can tie it: it is the one place that may import
everything. So the UI library **declares** what it needs, and the app shell **supplies** it.

## The seam

A seam is a small `Equatable` struct wrapping a factory closure, declared in a UI library and
read from the environment.

```swift
// Packages/lib-DesignSystem/Sources/DesignSystem/FeatureSeams.swift
import SwiftUI

/// Builds the settings screen. Injected by the app shell, called by whoever presents it.
///
/// `Equatable` on a stable `id` rather than a bare `() -> AnyView` environment value: SwiftUI
/// cannot compare function values, so a key holding a raw closure makes every reader invalidate
/// on *any* environment write. Comparing the id gives the framework an honest answer — two
/// seams built from the same registration are the same seam.
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
```

The app shell injects it — this is the only file that imports both features:

```swift
// App/Sources/ShelfApp.swift
import BookList
import Catalog
import Settings
import SwiftUI

var body: some Scene {
    WindowGroup {
        BookListView(viewModel: bookList)
            .environment(\.settingsContent, SettingsContent(id: "settings") {
                AnyView(SettingsView(settings: settings))
            })
    }
}
```

And the presenting feature calls it, knowing nothing about what it builds:

```swift
// Packages/fm-BookList/Sources/BookList/BookListView.swift
@Environment(\.settingsContent) private var settingsContent
@State private var isShowingSettings = false

// …in body:
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button("Settings", systemImage: "gear") { isShowingSettings = true }
    }
}
.sheet(isPresented: $isShowingSettings) {
    settingsContent()
}
```

`fm-BookList` gains no dependency on `fm-Settings`, in its sources or its manifest.

### Why not the obvious alternatives

| Instead of a seam | What it costs |
|---|---|
| Make the view generic over `SettingsDestination: View` | The generic leaks into every signature, preview and test that names the view. |
| Take an `@escaping @ViewBuilder` closure as a parameter | A function value cannot be compared, and the parameter has to be threaded through every caller. |
| Hand a `onSettingsTapped: () -> Void` up to the shell | The sheet stops belonging to the screen that presents it; each new presentation adds another boolean to the composition root. |
| Put a raw closure in the environment | SwiftUI cannot compare it, so every reader invalidates on any environment write. |

## The behaviour-hook variant

Same structure, one direction reversed: the seam carries behaviour *in* instead of content
*out*. The UI library declares the hook and the one-line modifier; the app shell supplies what it
does.

```swift
// Packages/lib-DesignSystem/Sources/DesignSystem/ScreenTracking.swift
import SwiftUI

/// Reports that a screen appeared. Injected by the app shell; the design system knows nothing
/// about analytics, and the analytics module knows nothing about SwiftUI.
public struct ScreenTracker: Equatable, Sendable {
    private let id: String
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
    func trackScreen(_ name: String) -> some View {
        modifier(TrackScreen(name: name))
    }
}
```

Injected once, in the app shell:

```swift
.environment(\.screenTracker, ScreenTracker(id: "analytics") { screen in
    analytics.track(event: "screen_view", parameters: ["screen": screen])
})
```

Which makes the per-screen cost exactly one line, with no new parameter and no new import:

```swift
.trackScreen("BookList")
```

Adding the twentieth screen is one line. Adding the second analytics vendor is one line, in the
shell.
