import Catalog
import Core
import DesignSystem
import SwiftUI

/// The shelf.
///
/// Settings is a sibling feature, so this view never imports it — the composition root hands in
/// the sheet's content instead, keeping the layering rule intact.
public struct BookListView<SettingsContent: View>: View {
    private let viewModel: BookListViewModel
    private let settingsContent: () -> SettingsContent

    @State private var isShowingSettings = false

    public init(
        viewModel: BookListViewModel,
        @ViewBuilder settingsContent: @escaping () -> SettingsContent
    ) {
        self.viewModel = viewModel
        self.settingsContent = settingsContent
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
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                settingsContent()
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
