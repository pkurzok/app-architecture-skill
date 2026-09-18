import Foundation

/// Abstraction over where notes are read from and written to.
/// `NotesStore` talks to this protocol instead of a concrete
/// storage mechanism, so the in-memory implementation used today
/// can be swapped for a disk- or database-backed one later
/// without touching the store's API or any feature that uses it.
public protocol NotesPersisting: Sendable {
    func loadNotes() -> [Note]
    func save(_ notes: [Note])
}

/// Default in-memory persistence. Good enough for the first
/// milestone, previews, and tests.
public final class InMemoryNotesPersistence: NotesPersisting, @unchecked Sendable {
    private var notes: [Note]
    private let lock = NSLock()

    public init(seed: [Note] = []) {
        self.notes = seed
    }

    public func loadNotes() -> [Note] {
        lock.lock(); defer { lock.unlock() }
        return notes
    }

    public func save(_ notes: [Note]) {
        lock.lock(); defer { lock.unlock() }
        self.notes = notes
    }
}
