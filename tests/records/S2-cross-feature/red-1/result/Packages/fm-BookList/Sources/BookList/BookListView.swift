import Catalog
import Core
import DesignSystem
import SwiftUI

/// The shelf.
///
/// Settings is a sibling feature, so this view never imports it — the architecture gate forbids a
/// feature depending on a feature. Instead the composition root hands in how to build the
/// settings screen, and this view only knows it can be shown.
public struct BookListView<SettingsDestination: View>: View {
    private let viewModel: BookListViewModel
    private let settingsDestination: () -> SettingsDestination

    @State private var isShowingSettings = false

    public init(
        viewModel: BookListViewModel,
        @ViewBuilder settingsDestination: @escaping () -> SettingsDestination
    ) {
        self.viewModel = viewModel
        self.settingsDestination = settingsDestination
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
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $isShowingSettings) {
            settingsDestination()
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
