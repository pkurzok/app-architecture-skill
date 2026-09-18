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
}
