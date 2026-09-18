import Foundation

/// Persists and retrieves notes. A feature reads and writes through this protocol and never
/// touches storage directly, so its tests can substitute a fake and a real persistence layer can
/// replace ``InMemoryNotesStore`` without the feature noticing.
public protocol NotesStore: Sendable {
    /// Every note, newest first.
    func fetchAll() async -> [Note]

    /// Inserts a new note, or replaces the one with the same id.
    func save(_ note: Note) async

    func delete(id: Note.ID) async
}
