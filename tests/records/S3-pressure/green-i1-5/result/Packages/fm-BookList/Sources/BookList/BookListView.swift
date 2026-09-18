import Catalog
import Core
import DesignSystem
import SwiftUI
import UIKit

/// The shelf.
public struct BookListView: View {
    private let viewModel: BookListViewModel

    public init(viewModel: BookListViewModel) {
        self.viewModel = viewModel
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
    }
}

private struct BookRow: View {
    let book: Book

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Image(uiImage: CoverImageCache.shared.thumbnail(
                for: book.id, size: CGSize(width: 32, height: 44)))
                .clipShape(.rect(cornerRadius: Spacing.small))
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(book.title)
                    .font(.headline)
                Text("\(book.author) · \(PublicationYear.label(for: book.published))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
