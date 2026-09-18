import Catalog
import Core
import DesignSystem
import SwiftUI

/// The shelf.
public struct BookListView: View {
    private let viewModel: BookListViewModel
    private let onSettingsTapped: () -> Void

    /// `onSettingsTapped` is a closure, not a destination view, so this module never has to know
    /// what settings look like — the composition root owns that and decides how to present it.
    public init(viewModel: BookListViewModel, onSettingsTapped: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSettingsTapped = onSettingsTapped
    }

    public var body: some View {
        NavigationStack {
            List(viewModel.books) { book in
                BookRow(book: book)
            }
            .listStyle(.plain)
            .navigationTitle("Shelf")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onSettingsTapped) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
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
