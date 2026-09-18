import Notes
import SwiftUI

/// The notes list screen: every note in the store, newest first, with add and swipe-to-delete.
public struct NotesListView: View {
    @State private var viewModel: NotesListViewModel
    @State private var newTitle = ""

    public init(viewModel: NotesListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("New note", text: $newTitle)
                            .onSubmit { Task { await addNote() } }
                        Button("Add") { Task { await addNote() } }
                            .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                Section {
                    ForEach(viewModel.notes) { note in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.title).font(.headline)
                            if !note.body.isEmpty {
                                Text(note.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .onDelete { offsets in Task { await viewModel.delete(at: offsets) } }
                }
            }
            .navigationTitle("Pocket")
            .task { await viewModel.load() }
        }
    }

    private func addNote() async {
        await viewModel.addNote(titled: newTitle)
        newTitle = ""
    }
}
