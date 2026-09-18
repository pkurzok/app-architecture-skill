import Core
import Foundation

/// Reads the shelf. In-memory for now; the async signature is what lets it become a database or
/// a network call later without a single caller changing.
public struct CatalogStore: Sendable {
    private let books: [Book]

    public init(books: [Book] = Book.sample) {
        self.books = books
    }

    public func load() async throws -> [Book] {
        books
    }

    public static func sorted(_ books: [Book], by order: BookSortOrder) -> [Book] {
        switch order {
        case .title: books.sorted { $0.title < $1.title }
        case .author: books.sorted { $0.author < $1.author }
        }
    }
}
