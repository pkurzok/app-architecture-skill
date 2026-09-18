import Foundation

/// An in-memory ``NotesStore``. The only implementation today; a persisted one (SwiftData, a
/// file, a server) can conform to the same protocol later without the feature noticing.
///
/// An actor, not a class: the store is shared with whatever concurrent callers a future feature
/// adds, and this keeps `notesByID` safe without the feature ever thinking about locking.
public actor InMemoryNotesStore: NotesStore {
    private var notesByID: [Note.ID: Note] = [:]

    public init(seed: [Note] = []) {
        for note in seed { notesByID[note.id] = note }
    }

    public func fetchAll() async -> [Note] {
        notesByID.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    public func save(_ note: Note) async {
        notesByID[note.id] = note
    }

    public func delete(id: Note.ID) async {
        notesByID[id] = nil
    }
}
