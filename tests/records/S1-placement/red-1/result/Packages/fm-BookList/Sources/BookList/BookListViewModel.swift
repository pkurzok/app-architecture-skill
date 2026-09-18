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

    /// Handed to the view too, so it can report the screen appearing without this view model
    /// needing to reach across an actor boundary to do it on the view's behalf.
    let analytics: Analytics

    private let store: CatalogStore
    private let settings: CatalogSettings

    public init(store: CatalogStore, settings: CatalogSettings, analytics: Analytics) {
        self.store = store
        self.settings = settings
        self.analytics = analytics
    }

    public func load() async {
        let loaded = (try? await store.load()) ?? []
        books = CatalogStore.sorted(loaded, by: settings.sortOrder)
        analytics.track(event: "book_list_loaded", parameters: ["count": String(books.count)])
    }
}
