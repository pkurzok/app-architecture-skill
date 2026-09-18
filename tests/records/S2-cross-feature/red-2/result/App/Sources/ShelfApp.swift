import Analytics
import BookList
import Catalog
import Settings
import SwiftUI

/// The composition root. It is the only place that may import every layer, so it is where the
/// stores are built and handed to the features that use them.
@main
struct ShelfApp: App {
    @State private var settings: CatalogSettings
    @State private var bookList: BookListViewModel
    @State private var isSettingsPresented = false

    init() {
        let settings = CatalogSettings()
        _settings = State(initialValue: settings)
        _bookList = State(initialValue: BookListViewModel(
            store: CatalogStore(),
            settings: settings,
            analytics: Analytics(sinks: [InMemoryAnalyticsSink()])
        ))
    }

    var body: some Scene {
        WindowGroup {
            BookListView(viewModel: bookList) {
                isSettingsPresented = true
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(settings: settings)
            }
        }
    }
}
