import SwiftUI
import NotesKit

/// The first feature screen: a list of notes read from and
/// mutated through a shared `NotesStore`. The view owns no
/// state of its own beyond the transient "new note" prompt.
public struct NotesListView: View {
    @Bindable private var store: NotesStore
    @State private var isAddingNote = false
    @State private var newNoteTitle = ""

    public init(store: NotesStore) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Group {
                if store.notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes Yet",
                        systemImage: "note.text",
                        description: Text("Tap + to add your first note.")
                    )
                } else {
                    List {
                        ForEach(store.notes) { note in
                            NoteRow(note: note)
                        }
                        .onDelete(perform: store.deleteNotes)
                    }
                }
            }
            .navigationTitle("Pocket")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingNote = true
                    } label: {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            .alert("New Note", isPresented: $isAddingNote) {
                TextField("Title", text: $newNoteTitle)
                Button("Cancel", role: .cancel) {
                    newNoteTitle = ""
                }
                Button("Add") {
                    let title = newNoteTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !title.isEmpty {
                        store.addNote(title: title)
                    }
                    newNoteTitle = ""
                }
            }
        }
    }
}

private struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)
            if !note.body.isEmpty {
                Text(note.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

#Preview {
    NotesListView(
        store: NotesStore(
            persistence: InMemoryNotesPersistence(seed: [
                Note(title: "Welcome to Pocket", body: "This is your first note."),
                Note(title: "Groceries", body: "Milk, eggs, bread")
            ])
        )
    )
}
