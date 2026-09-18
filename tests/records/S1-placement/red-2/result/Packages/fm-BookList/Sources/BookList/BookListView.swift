import Analytics
import Catalog
import Core
import DesignSystem
import SwiftUI

/// The shelf.
public struct BookListView: View {
    private let viewModel: BookListViewModel
    private let analytics: Analytics

    public init(viewModel: BookListViewModel, analytics: Analytics) {
        self.viewModel = viewModel
        self.analytics = analytics
    }

    public var body: some View {
        NavigationStack {
            List(viewModel.books) { book in
                BookRow(book: book)
            }
            .listStyle(.plain)
            .navigationTitle("Shelf")
        }
        .task {
            await viewModel.load()
        }
        .onAppear { analytics.trackScreenAppeared("BookList") }
    }
}

private struct BookRow: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(book.title)
                .font(.headline)
            Text("\(book.author) · \(PublicationYear.label(for: book.published))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
