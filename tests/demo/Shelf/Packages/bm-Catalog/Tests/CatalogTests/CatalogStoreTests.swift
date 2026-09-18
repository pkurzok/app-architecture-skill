import Foundation
import Testing
@testable import Catalog

@Suite("CatalogStore")
struct CatalogStoreTests {

    @Test("Loading returns the shelf it was built with")
    func loadReturnsItsBooks() async throws {
        let store = CatalogStore(books: Array(Book.sample.prefix(2)))
        #expect(try await store.load().count == 2)
    }

    @Test("Sorting by title and by author", arguments: [
        (BookSortOrder.title, ["Dune", "Kindred", "Zone One"]),
        (BookSortOrder.author, ["Zone One", "Dune", "Kindred"]),
    ])
    func sortsTheShelf(order: BookSortOrder, expected: [String]) {
        let sorted = CatalogStore.sorted(Book.sample, by: order)
        #expect(sorted.map(\.title) == expected)
    }

    @Test("A sort order knows what to call itself")
    func sortOrderHasALabel() {
        #expect(BookSortOrder.allCases.map(\.label) == ["Title", "Author"])
    }

    @MainActor
    @Test("Settings start sorted by title")
    func settingsDefaultToTitle() {
        #expect(CatalogSettings().sortOrder == .title)
    }
}
