import Foundation
import Observation

/// Owns the in-memory list of notes and is the single place
/// mutations happen. Any number of views can read from and
/// observe the same `NotesStore` instance instead of each
/// keeping its own copy of the data.
@MainActor
@Observable
public final class NotesStore {
    public private(set) var notes: [Note]

    private let persistence: NotesPersisting

    public init(persistence: NotesPersisting = InMemoryNotesPersistence()) {
        self.persistence = persistence
        self.notes = persistence.loadNotes().sorted { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    public func addNote(title: String, body: String = "") -> Note {
        let note = Note(title: title, body: body)
        notes.insert(note, at: 0)
        persistence.save(notes)
        return note
    }

    public func deleteNotes(at offsets: IndexSet) {
        // `Array.remove(atOffsets:)` lives in SwiftUI; this layer has
        // no UI dependency, so offsets are removed manually instead.
        for index in offsets.sorted(by: >) {
            notes.remove(at: index)
        }
        persistence.save(notes)
    }

    public func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        persistence.save(notes)
    }
}
