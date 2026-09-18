import Foundation
import Notes
import Observation

/// Drives the notes list screen: loads from the store, and keeps the on-screen list in sync with
/// every add or delete the person makes. Holds no storage of its own — that is the store's job.
@MainActor
@Observable
public final class NotesListViewModel {
    public private(set) var notes: [Note] = []

    private let store: NotesStore

    public init(store: NotesStore) {
        self.store = store
    }

    public func load() async {
        notes = await store.fetchAll()
    }

    public func addNote(titled title: String) async {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        await store.save(Note(title: trimmed))
        await load()
    }

    public func delete(at offsets: IndexSet) async {
        for id in offsets.map({ notes[$0].id }) {
            await store.delete(id: id)
        }
        await load()
    }
}
