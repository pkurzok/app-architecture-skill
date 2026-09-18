import Analytics
import Catalog
import Testing
@testable import BookList

@Suite("BookListViewModel")
@MainActor
struct BookListViewModelTests {

    @Test("Loading sorts the shelf the way the settings ask for")
    func loadSortsByTheChosenOrder() async {
        let settings = CatalogSettings(sortOrder: .author)
        let viewModel = BookListViewModel(
            store: CatalogStore(),
            settings: settings,
            analytics: Analytics()
        )

        await viewModel.load()

        #expect(viewModel.books.map(\.title) == ["Zone One", "Dune", "Kindred"])
    }

    @Test("trackScreenView forwards to analytics as a screen_view event")
    func trackScreenViewForwardsToAnalytics() {
        let sink = InMemoryAnalyticsSink()
        let viewModel = BookListViewModel(
            store: CatalogStore(),
            settings: CatalogSettings(),
            analytics: Analytics(sinks: [sink])
        )

        viewModel.trackScreenView("BookList")

        #expect(sink.events == [AnalyticsEvent(name: "screen_view", parameters: ["screen": "BookList"])])
    }
}
