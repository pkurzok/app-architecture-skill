import Analytics
import Catalog
import Foundation
import Observation

/// What the shelf screen shows, and everything it does to get there. The view stays a rendering
/// of this, so the interesting part is testable without a view.
@MainActor
@Observable
public final class BookListViewModel {
    public private(set) var books: [Book] = []

    private let store: CatalogStore
    private let settings: CatalogSettings
    private let analytics: Analytics

    public init(store: CatalogStore, settings: CatalogSettings, analytics: Analytics) {
        self.store = store
        self.settings = settings
        self.analytics = analytics
    }

    /// What the view calls once, when the screen appears. Exposed as just this, not the whole
    /// of `analytics`, so the view can't reach for anything wider than "report I appeared."
    public var trackScreenView: (String) -> Void { analytics.trackScreenView }

    public func load() async {
        let loaded = (try? await store.load()) ?? []
        books = CatalogStore.sorted(loaded, by: settings.sortOrder)
        analytics.track(event: "book_list_loaded", parameters: ["count": String(books.count)])
    }
}
