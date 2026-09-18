import Analytics
import BookList
import Catalog
import SwiftUI

/// The composition root. It is the only place that may import every layer, so it is where the
/// stores are built and handed to the features that use them.
@main
struct ShelfApp: App {
    @State private var settings: CatalogSettings
    @State private var bookList: BookListViewModel
    private let analytics: Analytics

    init() {
        let settings = CatalogSettings()
        let analytics = Analytics(sinks: [InMemoryAnalyticsSink()])
        _settings = State(initialValue: settings)
        _bookList = State(initialValue: BookListViewModel(
            store: CatalogStore(),
            settings: settings,
            analytics: analytics
        ))
        self.analytics = analytics
    }

    var body: some Scene {
        WindowGroup {
            BookListView(viewModel: bookList, analytics: analytics)
        }
    }
}
